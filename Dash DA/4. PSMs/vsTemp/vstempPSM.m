%% Creates a PSM for temperature sensitive trees using the vsTemp forward model.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRUCTOR:
% 
% obj = vstempPSM( obCoord, T1, T2, M1, M2, timeDA )
% Creates a PSM to run VS-Lite in Dash
%
% obj = vstempPSM( ..., 'intwindow', intwindow)
% Specifies the integration window.
%
% obj = vstempPSM( ..., 'convertT', convertT)
% Specify a value to use to convert T to degrees C
%
% ----- Inputs -----
%
% obCoord: [lat, lon] coordinates for the observation site.
%
% T1, T2: See "help vsTemp.m" for details.
%
% timeDA: The time steps that the DA is run over. Must be a datetime.
%
% intwindow: See "help vsTemp.m"
%
% convertT: A value that will be ADDED to DA T values to convert them to C
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE INDICES:
%
% H = getStateIndices(ensMeta, Tname, time )
% Determines the state indices to use to run VS-Lite for a site.
%
% ----- Inputs -----
%
% ensMeta: Metadata for an ensemble
%
% Tname: The name of the temperature variable
%
% time: A 12 element vector containing the metadata value for time in each
%       month. May be a cell or a vector.
%
classdef vstempPSM < PSM
    
    properties
        timeDA; % Time steps for the DA
        lat;
        lon;
        T1;
        T2;
        intwindow;
        
        convertT; % Add to T to convert to C
    end
    
    methods
        
        % Constructor
        function obj = vslitePSM( obCoord, T1, T2, timeDA, varargin )
            
            % Parse the advanced inputs
            [intwindow, convertT] = parseInputs( varargin, {'intwindow','convertT'},...
                                                              {[],0}, {[],[]} );
            
            % By default, let vslite select the integration window
            obj.intwindow = {};
            
            % If user specified, set the advanced inputs
            if ~isempty(intwindow)
                obj.intwindow = {'intwindow',intwindow};
            end

            % Set the T conversion
            obj.convertT = convertT;
            
            % Set the basic inputs
            obj.lat = obCoord(1);
            obj.lon = obCoord(2);
            obj.T1 = T1;
            obj.T2 = T2;
            
            % Require time to be a datetime
            if ~isdatetime(timeDA)
                error('timeDA must be a datetime.');
            end
            obj.timeDA = timeDA;
        end
        
        % Run the PSM
        function[trw] = runPSM( obj, T, ~, ~, t)
            
            % Get the year of the integration
            vsYear = year( obj.timeDA(t) );
            
            % Convert T to Celsius
            T = T + obj.convertT;
            
            % Run vsTemp
            trw = vsTemp( vsYear, vsYear, obj.lat, obj.T1, obj.T2, T, obj.intwindow{:} );
        end
            
        % Get the state vector indices
        function[H] = getStateIndices( obj, ensMeta, Tname, time )
            
            % Ensure that time has 12 elements
            if ~isvector(time) || numel(time)~=12
                error('Time must be a vector with 12 elements.');
            end
            
            % Get the variable's indices
            Tdex = varCheck(ensMeta, Tname);
            
            % Preallocate the output indices
            H = NaN(12,1);
            
            % For each month
            for t = 1:12
                
                % Find the indices of the variables in the current time
                Ttime = findincell( time(t), ensMeta.time(Tdex) );
                
                % Get the lat and lon coords
                Tlat = cell2mat(ensMeta.lat( Tdex(Ttime) ));
                Tlon = cell2mat(ensMeta.lon( Tdex(Ttime) ));
                
                % Get the closest site to the observatino
                Tsite = samplingMatrix( [obj.lat, obj.lon], [Tlat, Tlon], 'linear');
                
                % Save the sampling index
                H(t) = Tdex(Ttime(Tsite));
            end     
        end
    end
    
end