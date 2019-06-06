% This implements a general PSM for linear models with N variables.

% ----- Written  By -----
% Jonathan King, University of Arizona, 2019
classdef linearPSM < PSM
    
    properties
        slope;
        intercept;
        
        coord;
        varDex % State indices associated with each variable
    end
    
    methods
        
        % Constructor
        function obj = linearPSM( slope, intercept, lat, lon )
            
            % Check that slope and intercept are scalars
            if ~isvector(slope)
                error('slope must be a vector.')
            elseif ~isscalar(intercept)
                error('intercept must be a scalar.');
            % lat and lon should be scalars
            elseif ~isscalar(lat) || ~isscalar(lon)
                error('lat and lon must be scalars.');
            end
            
            % Save
            obj.slope = slope(:);
            obj.intercept = intercept;
            obj.coord = [lat, lon];
        end
        
        % State indices
        % vararg1 = list of variable names (for slope 1)
        % vararg2 = list of restriction indices (for slope 1)
        function[] = getStateIndices( obj, ensMeta, varargin )
            
            % Ensure the correct number of inputs
            nVar = length(obj.slope);
            if numel(varargin) ~= nVar*2
                error('There must be two inputs (a variable name and a cell of restriction indices) for each element of ''slope''.');
            end
            
            % Initialize H and the number of elements per variable
            obj.H = [];
            obj.varDex = zeros( nVar+1, 1 );
            
            % For each variable
            for v = 1:nVar
                
                % Get the state indices
                Hv = getClosestLatLonIndex( obj.coord, ensMeta, varargin{v*2-1}, varargin{v*2}{:} );
                
                % Add to array
                obj.H = [obj.H; Hv];
                
                % Record the number of indices (useful if taking means)
                obj.varDex(v+1) = numel(Hv);
            end
            
            % Take the cumulative sum to get the edges of variable indices
            obj.varDex = cumsum( obj.varDex );
        end
        
        % Error Check
        function[] = errorCheckPSM( obj )
            if isempty(obj.slope) || isempty(obj.intercept) || isempty(obj.varDex)
                error('The slope, intercept and varDex cannot be empty.');
            elseif any(isnan(obj.slope)) || any(isnan(obj.intercept)) || any(isnan(obj.varDex))
                error('The slope, intercept, and varDex cannot be NaN.');
            elseif ~isvector(obj.slope) || ~isvector(obj.varDex) || length(obj.slope)~=length(obj.varDex)-1
                error('The slope and varDex must be vectors. varDex must have one more element than slope.');
            elseif ~isscalar(obj.intercept)
                error('The intercept must be a scalar.');
            end
        end
       
        
        % Run the PSM
        function[Ye, R] = runForwardModel( obj, M, ~, ~ )
            
            % Preallocate the variables
            nVar = numel(obj.slope);
            var = NaN( nVar, size(M,2) );
            
            % Take all means
            for v = 1:nVar
                var(v,:) = mean( M( obj.varDex(v)+1 : obj.varDex(v+1), :), 1 );
            end
            
            % Apply the linear relationship
            Ye = sum( var .* obj.slope, 1 ) + obj.intercept;
            
            % Return an empty R
            R = [];
        end
    end
end