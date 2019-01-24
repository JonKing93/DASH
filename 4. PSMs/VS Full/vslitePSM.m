%% Implements a PSM for VS-Lite
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRUCTOR:
% 
% obj = vslitePSM( obCoord, T1, T2, M1, M2 )
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
%
% obCoord: [lat, lon] coordinates for the observation site.
%
% T1, T2, M1, M2: See "help VSLite_v2_5.m" for details.
%
% advParamsFlag: 'intwindow', 'lbparams', 'hydroclim'
%
% params: The parameter associated with each flag. See "help VSLite_v2_5.m"
%
% convertT: A value that will be ADDED to DA T values to convert them to C
%
% convertP: A value that will be MULTIPLIED by DA P values to convert to mm / month
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE INDICES:
%
% H = getStateIndices(ensMeta, Tname, Pname, time )
% Determines the state indices to use to run VS-Lite for a site.
%
% ----- Inputs -----
%
% ensMeta: Metadata for an ensemble
%
% Tname: The name of the temperature variable
%
% Pname: The name of the precipitation variable
%
% time: A 12 element vector containing the metadata value for time in each
%       month from January to December. May be a cell or numeric vector.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef vslitePSM < PSM
    
    properties
        lat;
        lon;
        T1;
        T2;
        M1;
        M2;
        intwindow;
        lbparams;
        hydroclim;
        
        convertT; % Add to T to convert to degrees C.
        convertP; % Multiply by P to convert to mm / month.
    end
        
    methods
        
        % Constructor
        function obj = vslitePSM( obCoord, T1, T2, M1, M2, varargin )
            
            % Parse the advanced inputs
            [lbparams, hydroclim, intwindow, convertT, convertP] = parseInputs( varargin, {'lbparams','hydroclim','intwindow','convertT','convertP'},...
                                                                                {[],[],[],0,1}, {[],{'P','M'},[],[],[]} );
            
            % By default, let vslite select the advanced inputs
            obj.lbparams = {};
            obj.intwindow = {};
            obj.hydroclim = {};
            
            % If user specified, set the advanced inputs
            if ~isempty(lbparams)
                obj.lbparams = {'lbparams', lbparams};
            end
            if ~isempty(intwindow)
                obj.intwindow = {'intwindow',intwindow};
            end
            if ~isempty(hydroclim)
                obj.hydroclmi = {'hydroclim',hydroclim};
            end
            
            % Set the T and P conversions
            obj.convertT = convertT;
            obj.convertP = convertP;
            
            % Set the basic inputs
            obj.lat = obCoord(1);
            obj.lon = obCoord(2);
            obj.T1 = T1;
            obj.T2 = T2;
            obj.M1 = M1;
            obj.M2 = M2;
            
        end
        
        % Run the PSM
        function[trw] = runPSM( obj, M, ~, ~, ~ )
                        
            % Split the ensemble elements into T and P
            T = M(1:12,:);
            P = M(13:24,:);
            
            % Convert T to Celsius
            T = T + obj.convertT;
            
            % Convert P to mm / month
            P = P .* obj.convertP;
            
            % Run VS-Lite
            trw = VSLite_v2_5( obj.lat, obj.T1, obj.T2, obj.M1, obj.M2, ...
                               T, P, obj.lbparams{:}, obj.intwindow{:}, obj.hydroclim{:} );
        end
        
        % Get the state vector indices
        function[H] = getStateIndices( obj, ensMeta, Tname, Pname, time )
            
            % Ensure that time has 12 elements
            if ~isvector(time) || numel(time)~=12
                error('Time must be a vector with 12 elements.');
            end
            
            % Get the variable's indices
            Tdex = varCheck(ensMeta, Tname);
            Pdex = varCheck(ensMeta, Pname);
            
            % Preallocate the output indices
            H = NaN(24,1);
            
            % For each month
            for t = 1:12
                
                % Find the indices of the variables in the current time
                Ttime = findincell( time(t), ensMeta.time(Tdex) );
                Ptime = findincell( time(t), ensMeta.time(Pdex) );w
                
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
                H(t+12) = Pdex(Ptime(Psite));
            end     
        end
    end
end
            