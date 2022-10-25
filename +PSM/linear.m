classdef linear < PSM.Interface
    %% PSM.linear  Implements a general linear model of form:  Y = Y = a1*X1 + a2*X2 + ... an*Xn + b
    % ----------
    %   The linear PSM implements a general linear forward model. The
    %   linear model uses the following form:
    %       Y = a1*X1 + a2*X2 + ... an*Xn + b
    %
    %   Each linear PSM can be customized for any N number of variables. 
    %   When initializing a linear PSM, the number of slopes provided
    %   determines N, the number of variables.
    %
    %   The linear PSM is directly built-in to the DASH toolbox, so does
    %   not need to be downloaded from an external Github repository.
    % ----------
    % linear Methods:
    %
    % *ALL USER METHODS*
    %
    % Create:
    %   linear      - Creates a new linear PSM object
    %   label       - Apply a label to a linear PSM object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold variables used as inputs to the linear model
    %   run         - Run a general linear model
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates proxy observations using a general linear model
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.linear')">Documentation Page</a>

    % Information about the codebase
    properties (Constant)
        estimatesR = false;             % The linear PSM cannot estimate R uncertainties       
        description = ...               % Description of the PSM
            "General linear model of form:  Y = Y = a1*X1 + a2*X2 + ... an*Xn + b"; 
        hasMemory = false;              % No memory of previous time steps

        repository = "DASH built-in";   % The linear PSM is built-in directly to DASH
        commit = "";                    % No repository = no commit
        commitComment = "";             % No commit = no comment
    end

    % Forward model parameters
    properties (SetAccess = private)
        slopes;     % Linear coefficients for the variables in the model
        intercept;  % Linear intercept
    end

    methods
        function[obj] = linear(slopes, intercept)
            %% PSM.linear.linear  Creates a new linear PSM object
            % ----------
            %   obj = <strong>PSM.linear</strong>(slopes)
            %   Initializes a new linear PSM object. The "slopes" input should have one
            %   element per variable in the linear model. The order of slopes should
            %   match the order of state vector rows / the order in which state vector
            %   variables are passed into the linear model. Uses an intercept of 0.
            %
            %   The subsequent linear forward model will use the form
            %       Y = slopes(1)*X1 + slopes(2)*X2 + ... slopes(N)*XN
            %
            %   obj = <strong>PSM.linear</strong>(slopes, intercept)
            %   Specify an intercept for the linear model. The subsequent linear model
            %   will have form:
            %       Y = slopes(1)*X1 + slopes(2)*X2 + ... slopes(N)*XN + intercept
            % ----------
            %   Inputs:
            %       slopes (numeric vector [nVariables]): The slopes / linear coefficients for the
            %           variables in the linear model. The number of slopes determines
            %           the number of variables used in the model.
            %       intercept (numeric scalar): An intercept for the linear model. By
            %           default, uses an intercept of 0.
            %
            %   Outputs:
            %       obj (scalar PSM.linear object): The new linear PSM object
            %
            % <a href="matlab:dash.doc('PSM.linear.linear')">Documentation Page</a>
            
            % Error check slopes.
            header = "DASH:PSM:linear";
            dash.assert.vectorTypeN(slopes, 'numeric', [], 'slopes', header);
            
            % Default and parse the intercept
            if ~exist('intercept', 'var')
                intercept = 0;
            else
                dash.assert.scalarType(intercept, 'numeric', 'intercept', header);
            end
            
            % Save parameters
            obj.slopes = slopes;
            obj.intercept = intercept;
        end
        function[output] = rows(obj, rows)
            %% PSM.linear.rows  Indicate the stateVector rows used to run a linear PSM
            % ----------
            %   obj = <strong>obj.rows</strong>(rows)
            %   Indicate the state vector rows that should be used as
            %   input for the linear PSM when calling the "PSM.estimate"
            %   command. The input is a column vector with one element
            %   per slope/linear coefficient in the forward model. Uses the
            %   same state vector rows for each ensemble member and each 
            %   ensemble in an evolving set.
            %
            %   obj = <strong>obj.rows</strong>(memberRows)
            %   Indicate which state vector rows to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with one row per linear slope,
            %   and one column per ensemble member.
            %
            %   obj = <strong>obj.rows</strong>(evolvingRows)
            %   Indicate which state vector rows to use for different ensembles in an 
            %   evolving set. This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [nSlopes x 1 x nEvolving] or of size 
            %   [nSlopes x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same rows for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use differents row for each ensemble member in each evolving ensemble.
            %
            %   rows = <strong>obj.rows</strong>
            %   Returns the current rows for the PSM object
            %
            %   obj = <strong>obj.rows</strong>('delete')
            %   Deletes any currently specified rows from the linear PSM object.
            % ----------
            %   Inputs:
            %       rows (column vector, linear indices [nSlopes]): 
            %           The state vector rows that hold the variables required to run
            %           the linear PSM. Uses the same rows for all ensemble members and
            %           ensembles in an evolving set.
            %       memberRows (matrix, linear indices [nSlopes x nMembers]): Indicates
            %           which state vector rows to use for each ensemble member. Should
            %           be a matrix with one row per linear slope and one column per
            %           ensemble member. Uses the same rows for the ensemble members in
            %           different evolving ensembles.
            %       evolvingRows (3D array, linear indices [nSlopes x 1|nMembers x nEvolving]):
            %           Indicates which state vector rows to use for different ensembles
            %           in an evolving set. Should be a 3D array, and the number of
            %           elements along the third dimension should match the number of
            %           ensembles in the evolving set. If the second dimension has a
            %           length of 1, uses the same rows for all the ensemble members in
            %           each evolving ensemble. If the second dimension has a length
            %           equal to the number of ensemble members, allows you to indicate
            %           which state vector rows to use for each ensemble member in each
            %           evolving ensemble.
            %
            %   Outputs:
            %       obj (scalar linear PSM object): The linear PSM with updated rows
            %       rows (linear indices, [nSlopes x 1|nMembers x 1|nEvolving]): The current
            %           rows for the linear PSM.
            %
            % <a href="matlab:dash.doc('PSM.linear.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                N = numel(obj.slopes);
                inputs = {rows, N};
            end
            output = obj.parseRows(inputs{:});
        end
        function[Y] = estimate(obj, X)
            %% PSM.linear.estimate  Estimates observations using a general linear model
            % ----------
            %   Y = <strong>obj.estimate</strong>(X)
            %   Runs the linear forward model on variable extracted from a
            %   state vector ensemble.
            % ----------
            %   Inputs:
            %       X (numeric array [nSlopes x nMembers x nEvolving]): The
            %           variables used as input to the linear model. Each
            %           row holds a variable. The order of variables should
            %           match the order of slopes for the linear model.
            %
            %   Outputs:
            %       Y (numeric matrix [1 x nMembers x nEvolving]): Observation
            %           estimates generated by running the linear forward
            %           model on the variables from the state vector ensemble
            % 
            % <a href="matlab:dash.doc('PSM.linear.estimate')">Documentation Page</a>

            % Run the linear model
            Y = PSM.linear.run(X, obj.slopes, obj.intercept);

        end
    end

    methods (Static)
        function[Y] = run(X, slopes, intercept)
            %% PSM.linear.run  Runs a general linear forward model
            % ----------
            %   Y = PSM.linear.run(X, slopes)
            %   Runs a general linear model on the input variables X using
            %   a set of input slopes/linear coefficients. Each row of X is
            %   a variable, and the order of variables should match the
            %   order of slopes. Uses a linear intercept of 0.
            %
            %   Y = PSM.linear.run(X, slopes, intercept)
            %   Specify a linear intercept to use for the linear model.
            % ----------
            %   Inputs:
            %       X (numeric array, [nVariables x ...]): The variables to
            %           use as input to the linear model. Each row of the
            %           input array is one variable.
            %       slopes (numeric vector [nVariables]): The linear
            %           coefficients/slopes associated with each of the
            %           input variables.
            %       intercept (numeric scalar): The linear intercept to use
            %           for the model. By default, uses an intercept of 0.
            %
            %   Outputs:
            %       Y (numeric array, [1 x ...]): The estimates generated
            %           by running the linear model.
            %
            % <a href="matlab:dash.doc('PSM.linear.run')">Documentation Page</a>

            % Error check
            header = "DASH:PSM:linear:run";
            dash.assert.type(X, 'numeric', 'X', 'array', header);
            N = size(X, 1);
            dash.assert.vectorTypeN(slopes, 'numeric', N, 'slopes', header);

            % Default and check intercept
            if ~exist('intercept', 'var')
                intercept = 0;
            else
                dash.assert.scalarType(intercept, 'numeric', 'intercept', header);
            end

            % Ensure slopes are a row vector for linear model
            if iscolumn(slopes)
                slopes = slopes';
            end

            % Implement a linear model
            Y = slopes * X + intercept;
        end
    end

end