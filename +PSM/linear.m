classdef linear < PSM.Interface
    % Implements a general linear PSM of the following form:
    %
    % Y = a1 X1 + a2 X2 + ... + an Xn + b
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties
        slopes;
        intercept;
    end
    
    methods
        % Constructor
        function[obj] = linear(rows, slopes, intercept, name)
            %% Creates a new linear PSM
            %
            % obj = linearPSM(rows, slopes, intercept)
            % Creates a linear PSM using a specified set of slopes and an
            % intercept.
            %
            % obj = linearPSM(rows, slopes, intercept, name)
            % Optionally names the PSM
            %
            % obj = linearPSM(rows, slope, ...)
            % Uses the same slope for all variables.
            %
            % obj = linearPSM(rows, slopes)
            % Uses a default intercept of 0.
            %
            % ----- Inputs -----
            %
            % rows: A list of state vector rows that indicate the data 
            %    values required to run the PSM. A vector of positive
            %    integers.
            %
            % slopes: The slopes for each variable. A numeric vector in the
            %    order as the listed rows.
            %
            % intercept: The intercept for the linear equation. A numeric
            %    scalar.
            %
            % name: An optional name for the PSM. A string
            %
            % ----- Outputs -----
            %
            % obj: The new linearPSM object
            
            % Set name, estimatesR, and rows
            if ~exist('name','var')
                name = "";
            end            
            obj@PSM.Interface(name, false);            
            obj = obj.useRows(rows);
            
            % Error check the slopes and intercept
            if ~exist('intercept','var')
                intercept = [];
            end
            [obj.slopes, obj.intercept] = obj.checkInputs(slopes, intercept, size(obj.rows,1));
        end
        
        % Run the PSM
        function[Y] = runPSM(obj, X)
            %% Runs a linearPSM object
            %
            % Y = obj.run(X)
            %
            % ----- Inputs -----
            %
            % X: The X values for the linear equation. A numeric matrix.
            %    Each row is a different X value.
            %
            % ----- Outputs -----
            %
            % Y: The output of the linear equation.
            
            Y = obj.run( X, obj.slopes, obj.intercept );
        end
    end

    methods (Static)
        % Run directly
        function[Y] = run(Xpsm, slopes, intercept)
            %% Runs a linear PSM directly
            %
            % Y = linearPSM.run(X, slopes, intercept)
            % Applies a linear equation to input values.
            %
            % Y = linearPSM.run(X, slope, intercept)
            % Uses the same slope for all variables.
            %
            % Y = linearPSM.run(X, slopes)
            % Uses a default intercept of 0.
            %
            % ----- Inputs -----
            % 
            % X: The X values for the linear equation. A numeric matrix.
            %    Each row is a different X value.
            %
            % slopes: The slopes for each variable. A numeric vector in the
            %    order as the listed rows. If a scalar, uses the same slope
            %    for all variables.
            %
            % intercept: The intercept for the linear equation. A numeric
            %    scalar.
            %
            % ----- Outputs -----
            %
            % Y: The output of the linear equation.
    
            % Error check X
            assert(isnumeric(Xpsm), 'Xpsm must be numeric');
            assert(ismatrix(Xpsm), 'Xpsm must be a matrix');
            
            % Default and error check slopes and intercept
            if ~exist('intercept','var')
                intercept = [];
            end
            [slopes, intercept] = PSM.linear.checkInputs(slopes, intercept, size(Xpsm,1));
            
            % Run the PSM
            Y = sum(slopes.*Xpsm, 1) + intercept;
        end
        
        % Error checking for object creating and run
        function[slopes, intercept] = checkInputs(slopes, intercept, nRows)
            %% Error checks slopes and intercepts for a linear equation and
            % sets default values.
            %
            % [slopes, intercept] = linearPSM.checkInputs(slopes, intercept, nRows)
            %
            % ----- Inputs -----
            %
            % slopes: Input slopes
            %
            % intercept: Input intercept
            %
            % nRows: The number of state vector rows / X variables used in
            %    the linear equation.
            %
            % ----- Outputs -----
            %
            % slopes: The final set of slopes.
            %
            % intercept: The intercept to use in the linear equation.

            % Error check the slopes
            dash.assert.vectorTypeN(slopes, 'numeric', [], 'slopes');
            dash.assert.realDefined(slopes, 'slopes');

            % Propagate a single slope over all rows. Otherwise check size
            nSlopes = numel(slopes);
            if nSlopes==1
                slopes = repmat(slopes, [nRows, 1]);
            elseif nSlopes~=nRows
                error('The number of slopes (%.f) does not match the number of rows (%.f)', nSlopes, nRows);
            end
            slopes = slopes(:);

            % Default and error check intercept
            if ~exist('intercept','var') || isempty(intercept)
                intercept = 0;
            end
            dash.assert.scalarType(intercept, 'intercept', 'numeric', 'numeric');
            dash.assert.realDefined(intercept, 'intercept');
        end
    end
end
            