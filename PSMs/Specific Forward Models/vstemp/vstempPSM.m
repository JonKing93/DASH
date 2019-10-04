classdef vstempPSM < PSM
    
    properties
        lat;
        lon;
        
        T1;
        T2;
        
        intwindowArg = {};
    end
    
    methods
        
        % Constructor
        function obj = vstempPSM( lat, lon, T1, T2, varargin )
            
            [intwindow] = parseInputs( varargin, {'intwindow'}, {[]}, {[]} );
                                                      
            % Advanced parameters
            if ~isempty(intwindow)
                obj.intwindowArg = {'intwindow', intwindow};
            end
            
            % Set values
            obj.lat = lat;
            obj.lon = lon;
            obj.T1 = T1;
            obj.T2 = T2;
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
        function[] = errorCheckPSM(obj)
            if ~isnumeric(obj.lat) || ~isnumeric(obj.T1) || ~isnumeric(obj.T2) || ...
               ~isscalar(obj.lat) || ~isscalar(obj.T1) || ~isscalar(obj.T2)
                error('lat, T1, and T2 must all be numeric scalars.');
            elseif obj.lat > 90 || obj.lat < -90
                error('The latitude of the PSM must be on the interval [-90 90].');
            elseif obj.T2 < obj.T1
                error('T2 must be greater than T1.');
            end
            
            if isempty(obj.intwindowArg) && numel(obj.H)~=12
                error('There must be 12 state indices.');
            elseif ~isempty(obj.intwindowArg) && numel(obj.H)~=numel(obj.intwindowArg{2})
                error('There must be one state index for each month in the integration window (intwindow).');
            end
        end
        
        
        % Run the PSM
        function[Ye,R] = runForwardModel( obj, M, ~, ~ )
            
            % Infill missing months with NaN
            T = NaN( 12, size(M,2) );
            T( obj.intwindowArg{2}, : ) = M;
            
            % Run the model
            Ye = vstemp( obj.lat, obj.T1, obj.T2, T, obj.intwindowArg{:} );
            
            R = NaN;
        end
        
    end
end
        