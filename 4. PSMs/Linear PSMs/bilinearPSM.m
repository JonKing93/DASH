% This implements a linear, bivariate PSM

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef bilinearPSM < PSM
    
    properties
        slope1;
        slope2;
        intercept;
        
        coord;
        
        addUnit;
        multUnit;
        
        nVar1;
        nVar2;
    end
    
    methods
        % Constructor
        function obj = bilinearPSM( slope1, slope2, intercept, lat, lon, varargin )
            
            % Check that slope and intercept are scalars
            if ~isscalar(slope1) || ~isscalar(slope2) || ~isscalar(intercept)
                error('slopes and intercepts must be scalars.');

            % lat and lon should be scalars
            elseif ~isscalar(lat) || ~isscalar(lon)
                error('lat and lon must be scalars.');
            end
            
            % Read in the optional unit conversion inputs
            [add, mult] = parseInputs( varargin, {'addUnit','multUnit'}, {0, 1}, {[],[]} );

            % Save
            obj.slope1 = slope1;
            obj.slope2 = slope2;
            obj.intercept = intercept;
            obj.coord = [lat, lon];
            obj.addUnit = add;
            obj.multUnit = mult;
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
        function[] = reviewPSM( obj )
            if isempty( obj.H )
                error('State indices were not generated.');
            end
            
            if isempty(obj.addUnit) || isempty(obj.multUnit) || isempty(obj.slope1) || isempty(obj.slope2) || isempty(obj.intercept)
                error('This PSM has properties with no associated values.');
            elseif any(isnan(obj.addUnit)) || any(isnan(obj.multUnit)) || isnan(obj.slope1) || isnan(obj.slope2) || isnan(obj.intercept)
                error('This PSM has properties with NaN elements.');
            elseif numel(obj.addUnit)~=numel(obj.H) || numel(obj.multUnit)~=numel(obj.H)
                error('addUnit and multUnit must have exactly one element for each state index.');
            end
        end
            
        % Convert Units
        function[M] = convertUnits( obj, M )
            M = M + obj.addUnit;
            M = M .* obj.multUnit;
        end
        
        % Run the PSM
        function[Ye] = runPSM( obj, M, ~, ~ )
            
            % Convert units
            M = obj.convertUnits(M);
            
            % Bias correct
            M = obj.biasCorrect(M);
            
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