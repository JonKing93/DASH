classdef linearPSM < PSM
    
    properties
        slopes;
        intercept;
    end
    
    methods
        % Constructor
        function[obj] = linearPSM(rows, slopes, intercept, name)
            
            % Default for empty name
            if ~exist('name','var')
                name = "";
            end
            
            % Superclass constructor
            obj@PSM(name, false);
            
            % Set the rows
            obj = obj.useRows(rows);
            
            % Error check the slopes
            dash.assertVectorTypeN(slopes, 'numeric', [], 'slopes');
            dash.assertRealDefined(slopes, 'slopes');
            
            % Propagate a single slope over all rows. Otherwise check size
            nRows = numel(obj.rows);
            nSlopes = numel(slopes);
            if nSlopes==1
                slopes = repmat(slopes, [nRows, 1]);
            elseif nSlopes~=nRows
                error('The number of slopes (%.f) does not match the number of rows (%.f)', nSlopes, nRows);
            end
            obj.slopes = slopes(:);
            
            % Default and error check the intercept
            if ~exist('intercept','var') || isempty(intercept)
                intercept = 0;
            end
            dash.assertScalarType(intercept, 'intercept', 'numeric', 'numeric');
            dash.assertRealDefined(intercept, 'intercept');
            obj.intercept = intercept;
        end
        
        % Run the PSM
        function[Y] = run(obj, X)
            Y = sum(obj.slopes.*X, 1) + obj.intercept;
        end
    end
    
end
            