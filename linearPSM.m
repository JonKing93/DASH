classdef linearPSM < PSM
    
    properties
        slopes;
        intercept;
    end
    
    methods
        % Constructor
        function[obj] = linearPSM(rows, slopes, intercept, name)
            
            % Set name, estimatesR, and rows
            if ~exist('name','var')
                name = "";
            end            
            obj@PSM(name, false);            
            obj = obj.useRows(rows);
            
            % Error check the slopes and intercept
            if ~exist('intercept','var')
                intercept = [];
            end
            [obj.slopes, obj.intercept] = linearPSM.checkInputs(slopes, intercept, numel(obj.rows));
        end
        
        % Run the PSM
        function[Y] = runPSM(obj, X)
            Y = sum(obj.slopes.*X, 1) + obj.intercept;
        end
    end

    methods (Static)
        % Run directly
        function[Y] = run(Xpsm, slopes, intercept)
    
            % Error check X
            assert(isnumeric(Xpsm), 'Xpsm must be numeric');
            assert(ismatrix(Xpsm), 'Xpsm must be a matrix');
            
            % Default and error check slopes and intercept
            if ~exist('intercept','var')
                intercept = [];
            end
            [slopes, intercept] = linearPSM.checkInputs(slopes, intercept, size(Xpsm,1));
            
            % Run the PSM
            Y = sum(slopes.*Xpsm, 1) + intercept;
        end
        
        % Error checking for object creating and run
        function[slopes, intercept] = checkInputs(slopes, intercept, nRows)

            % Error check the slopes
            dash.assertVectorTypeN(slopes, 'numeric', [], 'slopes');
            dash.assertRealDefined(slopes, 'slopes');

            % Propagate a single slope over all rows. Otherwise check size
            nSlopes = numel(slopes);
            if nSlopes==1
                slopes = repmat(slopes, [nRows, 1]);
            elseif nSlopes~=nRows
                error('The number of slopes (%.f) does not match the number of rows (%.f)', nSlopes, nRows);
            end

            % Default and error check intercept
            if ~exist('intercept','var') || isempty(intercept)
                intercept = 0;
            end
            dash.assertScalarType(intercept, 'intercept', 'numeric', 'numeric');
            dash.assertRealDefined(intercept, 'intercept');
        end
    end
end
            