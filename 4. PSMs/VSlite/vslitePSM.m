%% Implements a PSM for VS-Lite
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRUCTOR:
% 
% obj = vslitePSM( obCoord, T1, T2, M1, M2, Tclim )
% Creates a PSM to run VS-Lite in Dash
%
% obj = vslitePSM( ..., advParamsFlag, params)
% Specifies advanced parameters for VS-Lite. See "help VSLite_v2_5.m" for
% details.
%
% obj = vslitePSM( ..., 'convertT', convertT)
% obj = vslitePSM( ..., 'convertP', convertP)
% Specify a value to use to convert T or P in the DA to the units required
% for VS-Lite.
%
% ----- Inputs -----
% obCoord: [lat, lon] coordinates for the observation site.
%
% T1, T2, M1, M2: See "help VSLite4dash.m" for details.
%
% Tclim: A 12 element vector holding the monthly mean temperature
%   climatology (in Celsius) used to run the leaky bucket model.
%
% lbparams: Leaky-bucket parameters. See "help VSLite4dash.m" for details.
%
% intwindow: An array of positive integers on the interval [1, 12] indicating
%   the months for which a site is climate sensitive. In the Northern Hemisphere,
%   1 corresponds to January. In the Southern Hemisphere, 1 corresponds to
%   July. Default is [1:12].
%
%  ** Note that this is different from the implementation in VSLite_v2_5.
%     You must specify EACH sensitive month, not just the first and last **
% 
% hydroclim: Hydroclimate input flag. See "help VSLite4dash.m" for details.
%
% convertT: A value that will be ADDED to DA T values to convert them to C
%
% convertP: A value that will be MULTIPLIED by DA P values to convert to mm / month
%
% ----- Outputs -----
% obj: An instance of the vslitePSM class.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE INDICES:
%
% obj.getStateIndices(ensMeta, Tname, Pname, time )
% Determines the state indices to use to run VS-Lite for a site.
%
% ----- Inputs -----
% ensMeta: Metadata for an ensemble
%
% Tname: The name of the temperature variable
%
% Pname: The name of the precipitation variable
%
% time: Either a 12 element vector with the metadata values for each month,
%       OR a vector with metadata for each month in 'intwindow'.
%
%       If a 12 element vector, and the site is in the Northern hemisphere,
%       the metadata must be January-December.
%
%       If a 12 element vector and the site is in the Southern hemisphere,
%       the metadata must be July-June.
%
%       If matching metadata to 'intwindow', metadata must be in the same
%       order as the months in 'intwindow'.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STANDARDIZATION:
% In order to use a consistent standardization in DA, dash must
% pre-determine standardization weights using the initial ensemble.
%
% obj.setStandardization( M )
% Sets the standardization weights from the model ensemble.
%
% ----- Inputs -----
% M: An initial model ensemble.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef vslitePSM < PSM & biasCorrector
    
    properties
        % Site coordinates
        lat;
        lon;
        
        % VS Lite thresholds
        T1;
        T2;
        M1;
        M2;
        
        % Seasonality
        intwindow;
        
        % Monthly T climatology. (Used to run the leaky bucket model)
        Tclim;
        
        % Advanced inputs
        lbparams;
        hydroclim;
        
        % Fixed standardization
        standard;
        
        % DA unit conversions.
        convertT; % Added to DA T
        convertP; % Multiplied by DA P
    end
        
    methods
        
        % Constructor
        function obj = vslitePSM( obCoord, T1, T2, M1, M2, Tclim, varargin )
            
            % Parse the advanced inputs
            [lbparams, hydroclim, intwindow, convertT, convertP] = ...
                parseInputs( varargin, {'lbparams','hydroclim','intwindow','convertT','convertP'},...
                           {[],[],1:12,0,1}, {[], {'P','M'}, [], [], []} );
            
            % Defaults
            obj.lbparams = {};
            obj.hydroclim = {};
            
            % If user specified, set the advanced inputs
            if ~isempty(lbparams)
                obj.lbparams = {'lbparams', lbparams};
            end
            if ~isempty(hydroclim)
                obj.hydroclim = {'hydroclim',hydroclim};
            end
            
            % Set the seasonal sensitivity
            obj.intwindow = intwindow;
            
            % Set the temperature climatology
            obj.Tclim = Tclim;
            
            % Error check the T and P conversions
            if ~isscalar(convertT) && (~isvector(convertT) || length(convertT)~=length(intwindow))
                error('Temperature conversion must be a scalar or a column vector the length of the intwindow.');
            elseif ~isscalar(convertP) && (~isvector(convertP) || length(convertP)~=length(intwindow))
                error('Precipitaton conversion must be a scalar or a column vector the length of the intwindow.');
            end
            
            % Set conversions as column
            convertT = convertT(:);
            convertP = convertP(:);

            % Set the T and P conversions
            obj.convertT = convertT;
            obj.convertP = convertP;
            
            % Initialize the standardization
            obj.standard = [];
            
            % Set the basic inputs
            obj.lat = obCoord(1);
            obj.lon = obCoord(2);
            obj.T1 = T1;
            obj.T2 = T2;
            obj.M1 = M1;
            obj.M2 = M2;
        end
        
        % Get the state vector indices
        function[] = getStateIndices( obj, ensMeta, Tname, Pname, time )
            
            % Check that the variable names are allowed
            if ~isstrflag(Tname)
                error('Tname must be a string.');
            elseif ~isstrflag(Pname)
                error('Pname must be a string.');
            end
            
            % Concatenate variable names
            vars = [Tname;Pname];
            
            % Get the name of the time dimension
            [~,~,~,~,~,~,timeDim] = getDimIDs;x
            
            % If time has 12 elements, convert to intwindow
            if numel(time) == 12
                time = time(obj.intwindow);
            
            % Otherwise, if it doesn't match intwindow, throw an error
            elseif size(time,1) ~= numel(obj.intwindow)
                error('Time must have either 12 elements or an element for each month of seasonal sensitivity.');
            end
            
            % Get the indices
            obj.H = getClosestLatLonIndex( [obj.lat, obj.lon], ensMeta, ...
                                           vars, timeDim, time );
        end
        
        % Get the fixed standardization values
        function[obj] = setStandardization(obj, M)
            
            % Check that the H indices have been created
            if isempty(obj.H)
                error('The state indices have not been generated. Please run the "getStateIndices" method first.');
            end
            
            % Delete any old standardization
            obj.standard = [];
            
            % Run the PSM 
            trw = obj.runPSM( M(obj.H,:) );
            
            % Get the mean and standard deviation
            obj.standard(1) = mean(trw);
            obj.standard(2) = std(trw);
        end   
        
        % Run the PSM
        function[trw] = runPSM( obj, M, ~, ~ )
                        
            % Get some sizes
            [nMonth, nEns] = size(M);
            nMonth = nMonth / 2;
            
            % Apply bias correction (this will also convert units)
            M = obj.biasCorrect( M );
            
            % Preallocate T and P
            T = NaN(12, nEns);
            P = NaN(12, nEns);
            
            % Split the state vector into T and P for the seasonally
            % sensitive months.
            T(obj.intwindow,:) = M(1:nMonth,:);
            P(obj.intwindow,:) = M(nMonth+1:end,:);
            
            % Run VS-Lite
            trw = VSLite4dash( obj.lat, obj.T1, obj.T2, obj.M1, obj.M2, ...
                               T, P, obj.standard, obj.Tclim, 'intwindow', obj.intwindow, ...
                               obj.lbparams{:}, obj.hydroclim{:} );
        end
        
        % Converts DA units
        function[M] = convertM(obj, M)
            
            % Get the number of elements per variable
            nEls = size(M,1) / 2;
            
            % Convert T
            M(1:nEls,:) = M(1:nEls,:) + obj.convertT;
            
            % Convert P
            M(nEls+1:end,:) = M(nEls+1:end,:) .* obj.convertP;
        end
    end
end