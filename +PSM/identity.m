classdef identity < PSM.Interface
    %% PSM.identity  Implements an identity "forward model"
    % ----------
    %   The identity PSM returns any inputs values directly as output. It
    %   does not run a model of any sort.
    %
    %   The identity PSM is built in to the DASH toolbox, so it does not
    %   need to be downloaded from an external repository.
    % ----------
    % identity Methods:
    %
    % *ALL USER METHODS*
    %
    % Create:
    %   identity    - Creates a new identity PSM object
    %   label       - Apply a label to an identity PSM object
    %
    % Estimate:
    %   rows        - Indicate the state vector row that holds the input for the identity PSM
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimate proxy records using an identity operation
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.identity')">Documentation Page</a>

    % Information about the code
    properties (Constant)
        estimatesR = false;             % The identity PSM cannot estimate R
        description = ...               % Description of the PSM
            "Returns inputs directly as outputs. Does not run any forward model.";
        hasMemory = false;              % No memory of previous time steps
        
        repository = "DASH built-in";   % The identity PSM is built-in to DASH
        commit = "";                    % No repository = no commit
        commitComment = "";             % No commit = no comment
    end

    methods
        function[obj] = identity
            %% PSM.identity.identity  Creates a new identity PSM object
            % ----------
            %   obj = <strong>PSM.identity</strong>
            %   Creates a new identity PSM. This PSM returns any input
            %   values directly as output. It does not run any forward
            %   model.
            % ----------
            %   Outputs:
            %       obj (scalar PSM.identity object): The new identity PSM object
            %
            % <a href="matlab:dash.doc('PSM.identity.identity')">Documentation Page</a>
        end
        function[output] = rows(obj, row)
            %% PSM.identity.rows  Indicate the stateVector row used to run an identity PSM
            % ----------
            %   obj = <strong>obj.rows</strong>(row)
            %   Indicate the state vector row that should be used as the SST
            %   input for the linear PSM when calling the "PSM.estimate"
            %   command. The input is a scalar. Uses the same state vector
            %   row for each ensemble member and each ensemble in an evolving set.
            %
            %   obj = <strong>obj.rows</strong>(memberRows)
            %   Indicate which state vector rows to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a row vector with one
            %   element per ensemble member.
            %
            %   obj = <strong>obj.rows</strong>(evolvingRows)
            %   Indicate which state vector rows to use for different ensembles in an 
            %   evolving set. This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [1 x 1 x nEvolving] or of size 
            %   [1 x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same rows for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use differents row for each ensemble member in each evolving ensemble.
            %
            %   rows = <strong>obj.rows</strong>
            %   Returns the current rows for the PSM object
            %
            %   obj = <strong>obj.rows</strong>('delete')
            %   Deletes any currently specified rows from the identity PSM object.
            % ----------
            %   Inputs:
            %       row (column vector, linear indices [nSlopes]): 
            %           The state vector row that hold the variable used to run
            %           the identity PSM. Uses the same row for all ensemble members and
            %           ensembles in an evolving set.
            %       memberRows (matrix, linear indices [nSlopes x nMembers]): Indicates
            %           which state vector rows to use for each ensemble member. Should
            %           be a row vector with one element per ensemble member. Uses the
            %           same rows for the ensemble members in different evolving ensembles.
            %       evolvingRows (3D array, linear indices [1 x 1|nMembers x nEvolving]):
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
            %       obj (scalar PSM.identity object): The identity PSM with updated rows
            %       rows (linear indices, [nSlopes x 1|nMembers x 1|nEvolving]): The current
            %           rows for the identity PSM.
            %
            % <a href="matlab:dash.doc('PSM.identity.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('row', 'var')
                inputs = {row, 1};
            end
            output = obj.parseRows(inputs{:});
        end
        function[Ye] = estimate(~, Ye)
            %% PSM.identity.estimate  Returns inputs values directly as the estimates
            % ----------
            %   Ye = <strong>obj.estimate</strong>(Ye)
            %   Runs the identity operation on variables extracted from a
            %   state vector ensemble.
            % ----------
            %   Inputs:
            %       Ye (numeric array [1 x nMembers x nEvolving]): The
            %           data used as input to the identity operation.
            %
            %   Outputs:
            %       Ye (numeric array [1 x nMembers x nEvolving]): The
            %           inputs to the identity operation.
            %
            % <a href="matlab:dash.doc('PSM.identity.estimate')">Documentation Page</a>
        end
    end

end