%% This PSM implements VS-Lite for a single site.
% !!! Should implement later for multiple sites
classdef vslitePSM < PSM
    
    % Properties that cannot change once specified
    properties (SetAccess = immutable)
        lat;  % Site latitude
        time; % Time indexing
    end
    
    % Properties that can be changed
    properties
        season;
        T1;
        T2;
        M1;
        M2;
        advArgs;
    end
    
    methods
        
        %% Constructor for vslite. 
        function[obj] = vslitePSM( time, lat, Tthresh, Mthresh, season, varargin )
            
            % Set the value of lat and time
            obj.lat = lat;
            obj.time = time;
            
            % Set the thresholds
            obj.T1 = Tthresh(1);
            obj.T2 = Tthresh(2);
            obj.M1 = Mthresh(1);
            obj.M2 = Mthresh(2);
            
            % Get the integration window
            if nargin > 4
                obj.season = season;
            else
                obj.season = 1:12;
            end
                        
            % If specified, set some advanced parameters.
            if nargin > 5
                obj.advArgs = varargin;
            end
        end
        
        % Run VS-Lite
        function[Ye] = runPSM( obj, M, ~, ~, ~, tdex )
            
            % Start by getting the start / end years from the time indexing
            simYear = obj.time(tdex);
            
            % Get the state variables
            nVar = numel(obj.season);
            T = M( 1:nVar );
            P = M( nVar+1:end );
            
            % Run VS-Lite
            [Ye] = VSLite_v2_5( simYear, simYear, obj.lat, obj.T1, obj.T2, ...
                                 obj.M1, obj.M2, T, P, 'intwindow', obj.season, ...
                                 obj.advArgs{:} );
        end
        
    end
end
            
    