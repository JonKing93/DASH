% This implements a linear, bivariate PSM

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef bilinearPSM < PSM
    
    properties
        slope1;
        slope2;
        intercept;
        
        coord;
        
        nVar1;
        nVar2;
    end
    
    methods
        % Constructor
        function obj = bilinearPSM( slope1, slope2, intercept, lat, lon )
            
            % Check that slope and intercept are scalars
            if ~isscalar(slope1) || ~isscalar(slope2) || ~isscalar(intercept)
                error('slopes and intercepts must be scalars.');

            % lat and lon should be scalars
            elseif ~isscalar(lat) || ~isscalar(lon)
                error('lat and lon must be scalars.');
            end

            % Save
            obj.slope1 = slope1;
            obj.slope2 = slope2;
            obj.intercept = intercept;
            obj.coord = [lat, lon];
        end
        
        % State indices.
        function[] = getStateIndices( obj, ensMeta, var1, var1Args, var2, var2Args )
            
            % State indices for the first variable.
            H1 = getClosestLatLonIndex( obj.coord, ensMeta, var1, var1Args{:} );
            
            % State indices for the second variable. (Can allow separate
            % mean values for ensemble metadata)
            H2 = getClosestLatLonIndex( obj.coord, ensMeta, var2, var2Args{:} );
            
            % Record the number of each variable
            obj.nVar1 = numel(H1);
            obj.nVar2 = numel(H2);
            
            % Concatenate to get final indices
            obj.H = [H1; H2];
        end
            
        % Review PSM
        function[] = errorCheckPSM( obj )
            
            if isempty(obj.slope1) || isempty(obj.slope2) || isempty(obj.intercept)
                error('The slopes and intercept cannot be empty.');
            elseif isnan(obj.slope1) || isnan(obj.slope2) || isnan(obj.intercept)
                error('The slopes and intercept cannot be NaN.');
            elseif ~isnumeric(obj.slope1) || ~isnumeric(obj.slope2) || ~isnumeric(obj.intercept) || ...
                    ~isscalar(obj.slope1) || ~isscalar(obj.slope2) || ~isscalar(obj.intercept)
                error('The slopes and intercept must be numeric scalars.');
            end
        end
        
        % Run the PSM
        function[Ye] = runForwardModel( obj, M, ~, ~ )
            
            % Get the indices of elements associated with each variable
            index1 = 1:obj.nVar1;
            index2 = obj.nVar1 + (1:obj.nVar2);
            
            % Take any mean over the variables
            X1 = mean( M( index1, :), 1 );
            X2 = mean( M( index2, :), 1 );
            
            % Apply the linear relationship
            Ye = (X1 .* obj.slope1) + (X2 .* obj.slope2) + obj.intercept;
        end
    end
end