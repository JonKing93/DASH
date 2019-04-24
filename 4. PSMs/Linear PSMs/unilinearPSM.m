% This implements a linear, univariate PSM

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef unilinearPSM < PSM
    
    properties
        slope;
        intercept;
        
        coord;
        
        addUnit;
        multUnit;
    end
    
    methods
        % Constructor
        function obj = linearPSM( slope, intercept, lat, lon, varargin )

            % Check that slope and intercept are scalars
            if ~isscalar(slope) || ~isscalar(intercept)
                error('slopes and intercepts must be scalars.');

            % lat and lon should be scalars
            elseif ~isscalar(lat) || ~isscalar(lon)
                error('lat and lon must be scalars.');
            end

            % Read in the optional unit conversion inputs
            [add, mult] = parseInputs( varargin, {'addUnit','multUnit'}, {0, 1}, {[],[]} );

            % Error check unit conversion
            if ~isscalar(add) || isscalar(mult)
                error('The unit conversions must be scalars.');
            end

            % Save
            obj.slope = slope;
            obj.intercept = intercept;
            obj.coord = [lat, lon];
            obj.addUnit = add;
            obj.multUnit = mult;
        end
        
        % State indices. Will take the mean of all state indices
        function[] = getStateIndices( obj, ensMeta, varName, varargin )
            obj.H = getClosestLatLonIndex( obj.coord, ensMeta, varName, varargin );
        end
        
        % Error check the PSM
        function[] = reviewPSM( obj )
            if isempty( obj.H )
                error('State indices were not generated.');
            end
            
            if isempty(obj.addUnit) || isempty(obj.multUnit) || isempty(obj.slope) || isempty(obj.intercept)
                error('This PSM has properties with no associated values.');
            elseif isnan(obj.addUnit) || isnan(obj.multUnit) || isnan(obj.slope) || isnan(obj.intercept)
                error('This PSM has properties with NaN elements.');
            end
        end
        
        % Convert units
        function[M] = convertUnits( obj, M )
            M = M + obj.addUnit;
            M = M .* obj.multUnit;
        end
            
        % Run the PSM
        function[Ye] = runPSM( obj, M, ~, ~ )
            
            % Convert units
            M = obj.convertUnits(M);
            
            % Take the mean if multiple variables are sampled
            M = mean(M,1);
            
            % Do the linear model
            Ye = M .* obj.slope + obj.intercept;
        end
    end
end
