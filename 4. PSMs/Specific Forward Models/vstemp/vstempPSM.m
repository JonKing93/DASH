classdef vstempPSM < PSM
    
    properties
        lat;
        lon;
        
        T1;
        T2;
        
        intwindowArg = {};
        
        addUnit;
        multUnit;
    end
    
    methods
        
        % Constructor
        function obj = vstempPSM( lat, lon, T1, T2, varargin )
            
            [intwindow, addUnit, multUnit] = parseInputs( varargin, {'intwindow','addUnit','multUnit'}, ...
                                                          {[], zeros(12,1), ones(12,1)}, {[], [] []} );
                                                      
            % Advanced parameters
            if ~isempty(intwindow)
                obj.intwindowArg = {'intwindow', intwindow};
            end
            
            % Set values
            obj.lat = lat;
            obj.lon = lon;
            obj.T1 = T1;
            obj.T2 = T2;
            obj.addUnit = addUnit;
            obj.multUnit = multUnit;
        end
        
        % State indices
        function[] = getStateIndices( obj, ensMeta, Tname, monthNames, varargin )
            
            % Get the time dimension
            [~,~,~,~,~,~,timeID] = getDimIDs;
            
            % Get the closest indices
            obj.H = getClosestLatLonIndex( [obj.lat, obj.lon], ensMeta, ...
                                           Tname, timeID, monthNames, varargin{:} );
        end
        
        % Error Checking
        function[] = reviewPSM(obj)
        end
        
        % Convert Units
        function[M] = convertUnits( obj, M )
            M = M + obj.addUnit;
            M = M .* obj.multUnit;
        end
        
        % Run the PSM
        function[Ye] = runPSM( obj, T, ~, ~ )
            
            % Convert units
            T = obj.convertUnits( T );
            
            % Bias correct
            T = obj.biasCorrect( T );
            
            % Run the moel
            Ye = vstemp( obj.lat, obj.T1, obj.T2, T, obj.intwindowArg{:} );
        end
        
    end
end
        