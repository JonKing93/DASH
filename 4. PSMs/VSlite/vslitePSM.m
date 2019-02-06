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
% obj = vslitePSM( ..., 'Tbias', Tbias )
% obj.vslitePSM( ..., 'Pbias', Pbias )
% Specify a value to add to T or P in the DA to apply additive bias
% correction.
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
% Tbias: A scalar in Celsius that will be ADDED to DA T values for bias correction.
%
% Pbias: A scalar in mm / month that will be ADDED to DA P values for bias correction.
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
classdef vslitePSM < PSM
    
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
        
        % Bias correction
        Tbias;
        Pbias;
    end
        
    methods
        
        % Constructor
        function obj = vslitePSM( obCoord, T1, T2, M1, M2, Tclim, varargin )
            
            % Parse the advanced inputs
            [lbparams, hydroclim, intwindow, convertT, convertP, Tbias, Pbias] = ...
                parseInputs( varargin, {'lbparams','hydroclim','intwindow','convertT','convertP', 'Tbias', 'Pbias'},...
                           {[],[],1:12,0,1,0,0}, {[], {'P','M'}, [], [], [],[],[]} );
            
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
            
            % Set the T and P conversions
            obj.convertT = convertT;
            obj.convertP = convertP;
            
            % Add the bias corrections
            obj.Tbias = Tbias;
            obj.Pbias = Pbias;
            
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
        function[H] = getStateIndices( obj, ensMeta, Tname, Pname, time )
            
            % Error check
            if ~isvector(time)
                error('Time must be a vector.');
            end
            
            % Get the number of sensitive months
            nTime = numel(obj.intwindow);
            
            % If time has 12 elements, convert to intwindow
            if numel(time) == 12
                time = time(obj.intwindow);
            
            % Otherwise, if it doesn't match intwindow, throw an error
            elseif numel(time)~=nTime
                error('Time must have either 12 elements or an element for each month of seasonal sensitivity.');
            end
            
            % Get the variable's indices
            Tdex = varCheck(ensMeta, Tname);
            Pdex = varCheck(ensMeta, Pname);
            
            % Preallocate the output indices
            H = NaN(nTime*2,1);
            
            % For each month
            for t = 1:nTime
                
                % Find the indices of the variables in the current time
                Ttime = findincell( time(t), ensMeta.time(Tdex) );
                Ptime = findincell( time(t), ensMeta.time(Pdex) );
                
                % Get the lat and lon coords
                Tlat = cell2mat(ensMeta.lat( Tdex(Ttime) ));
                Tlon = cell2mat(ensMeta.lon( Tdex(Ttime) ));
                
                Plat = cell2mat(ensMeta.lat( Pdex(Ptime) ));
                Plon = cell2mat(ensMeta.lon( Pdex(Ptime) ));
                
                % Get the closest site for each variable
                Tsite = samplingMatrix( [obj.lat, obj.lon], [Tlat, Tlon], 'linear');
                Psite = samplingMatrix( [obj.lat, obj.lon], [Plat, Plon], 'linear');
                
                % Save the sampling index
                H(t) = Tdex(Ttime(Tsite));
                H(t+nTime) = Pdex(Ptime(Psite));
            end     
            
            % Save the sample indices
            obj.H = H;
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
            
            % Preallocate T and P
            nEns = size(M,2);
            T = NaN(12, nEns);
            P = NaN(12, nEns);
            
            % Split the state vector into T and P for the seasonally
            % sensitive months.
            nMonth = size(M,1) / 2;
            
            T(obj.intwindow,:) = M(1:nMonth,:);
            P(obj.intwindow,:) = M(nMonth+1:end,:);
            
            % Convert T to Celsius and apply bias correction
            T = T + obj.convertT; + obj.Tbias;
            
            % Convert P to mm / month and apply bias correction
            P = P .* obj.convertP + obj.Pbias;
            
            % Run VS-Lite
            trw = VSLite4dash( obj.lat, obj.T1, obj.T2, obj.M1, obj.M2, ...
                               T, P, obj.standard, obj.Tclim, 'intwindow', obj.intwindow, ...
                               obj.lbparams{:}, obj.hydroclim{:} );
        end
        
    end
end