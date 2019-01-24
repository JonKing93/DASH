%% Implements a PSM for temperature sensitive trees using the vsTemp forward model.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRUCTOR:
% 
% obj = vstempPSM( obCoord, T1, T2, M1, M2 )
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
% intwindow: See "help vsTemp.m" By default, is set to [1, 12]. Must be on
%       the interval 1:12.
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
% time: A vector containing the metadata value for time in each integration
%       month. Must contain an element for each month in the integration
%       window. May be a cell or numeric vector.
%
classdef vstempPSM < PSM
    
    properties
        lat;
        lon;
        T1;
        T2;
        intwindowArg; % The input passed to vsTemp
        intwindow; % The first and last month in the integration window.
        
        convertT; % Add to T to convert to C
    end
    
    methods
        
        % Constructor
        function obj = vstempPSM( obCoord, T1, T2, varargin )
            
            % Parse the advanced inputs
            [intwindow, convertT] = parseInputs( varargin, {'intwindow','convertT'},...
                                                              {[],0}, {[],[]} );
            
            % By default, let vslite select the integration window
            obj.intwindowArg = {};
            obj.intwindow = 1:12;
            
            % If user specified, set the advanced inputs
            if ~isempty(intwindow)
                
                % Check that the intwindow is a month from 1:12
                if ~any( ismember(intwindow, 1:12) )
                    error('intwindow must be months on the interval 1:12');
                end
                
                % Set the input arg and actual window
                obj.intwindowArg = {'intwindow',intwindow};
                obj.intwindow = min(intwindow):max(intwindow);
            end

            % Set the T conversion
            obj.convertT = convertT;
            
            % Set the basic inputs
            obj.lat = obCoord(1);
            obj.lon = obCoord(2);
            obj.T1 = T1;
            obj.T2 = T2;
        end
        
        % Run the PSM
        function[trw] = runPSM( obj, T, ~, ~, ~)
            
            % Convert T to Celsius
            T = T + obj.convertT;
            
            % Ensure a 12 month input
            Tfull = T;
            if size(T,1) < 12
                Tfull = NaN(12, size(T,2));
                Tfull( obj.intwindow, : ) = T;
            end            
            
            % Run vsTemp
            trw = vsTemp( obj.lat, obj.T1, obj.T2, Tfull, obj.intwindowArg{:} );
        end
            
        % Get the state vector indices
        function[H] = getStateIndices( obj, ensMeta, Tname, time )
            
            % Ensure that time has an element for each integration month
            if ~isvector(time) || numel(time)~=numel(obj.intwindow)
                error('Time must be a vector with an element for each month in the integration window.');
            end
            
            % Get the variable's indices
            Tdex = varCheck(ensMeta, Tname);
            
            % Preallocate the output indices
            H = NaN(numel(time),1);
            
            % For each month
            for t = 1:numel(obj.intwindow)
                
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