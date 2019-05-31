% This implements a linear, univariate PSM

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef unilinearPSM < PSM
    
    properties
        slope;
        intercept;
        
        coord;
    end
    
    methods
        % Constructor
        function obj = unilinearPSM( slope, intercept, lat, lon )

            % Check that slope and intercept are scalars
            if ~isscalar(slope) || ~isscalar(intercept)
                error('slopes and intercepts must be scalars.');

            % lat and lon should be scalars
            elseif ~isscalar(lat) || ~isscalar(lon)
                error('lat and lon must be scalars.');
            end

            % Save
            obj.slope = slope;
            obj.intercept = intercept;
            obj.coord = [lat, lon];
        end
        
        % State indices. Will take the mean of all state indices
        function[] = getStateIndices( obj, ensMeta, varName, varargin )
            obj.H = getClosestLatLonIndex( obj.coord, ensMeta, varName, varargin{:} );
        end
        
        % Error check the PSM
        function[] = errorCheckPSM( obj )
            
            if isempty(obj.slope) || isempty(obj.intercept)
                error('The slope or intercept is empty.');
            elseif isnan(obj.slope) || isnan(obj.intercept)
                error('The slope or intercept is NaN.');
            elseif ~isscalar(obj.slope) || ~isscalar(obj.intercept) || ~isnumeric(obj.slope) || ~isnumeric(obj.intercept)
                error('The slope and intercept must be numeric scalars.');
            end
        end
            
        % Run the PSM
        function[Ye] = runForwardModel( obj, M, ~, ~ )
            
            % Take the mean if multiple variables are sampled
            M = mean(M,1);
            
            % Do the linear model
            Ye = M .* obj.slope + obj.intercept;
        end
    end
end
