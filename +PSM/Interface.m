classdef (Abstract) Interface
    %% PSM.Interface  Defines a common interface for working with forward models
    % ----------
    %   The PSM.Interface defines an interface that allows users to work
    %   with a variety of forward models using a common set of commands.
    %   This interface is specifically designed to facilitate use of the
    %   "PSM.estimate" command, which allows users to apply a collection
    %   of forward models to a state vector ensemble.
    %
    %   Key Commands:
    %   For users, the key commands in the interface are as follows.
    %   1. You can create an object for a particular type of forward model
    %      using PSM.<model type> For example, "PSM.linear" creates new
    %      linear forward model, and "PSM.bayspar" creates an object that
    %      implements the BaySPAR forward model.
    %   2. You can optionally label a forward model object by calling
    %      the "label" command on the object. You can also return the
    %      current label of a forward model using this command.
    %   3. Indicate which state vector rows contain the inputs required to
    %      run the forward model by calling the "rows" command on the
    %      object. In addition to a fixed set of state vector rows, the
    %      "rows" command also allows users to optionally assign different
    %      state vector rows to different ensemble members and/or ensembles
    %      in an evolving set.
    %
    %   In addition to these user commands, the PSM interface also requires
    %   PSM objects to implement an "estimate" command, which runs the
    %   forward model on inputs extracted from a state vector ensemble.
    %   These estimate methods are essentially wrappers to whatever
    %   external code actually runs the forward model, and they are used by
    %   the "PSM.estimate" method to run any input forward models. The
    %   interface also requires PSM objects to indicate whether they can
    %   estimate R uncertainties or not. This is also used to help run the
    %   PSM.estimate method.
    %
    %   The interface requires PSM classes to also define several constant
    %   properties that relate to the location of the forward model
    %   codebase on Github, and also a description of the forward model.
    %   These properties are used to implement the PSM.info,
    %   PSM.githubInfo, and PSM.download commands.
    %
    %   Finally, the interface implements several common utilities for
    %   working with PSM objects. These utilities allow developers to
    %   quickly develop new PSMs with a minimum of new code.
    % ----------
    % Interface Methods:
    %
    % *ALL USER METHODS*
    %
    % Interface:
    %   label   - Optionally apply a label to a PSM object
    %   rows    - Indicate the state vector rows required to run a forward model
    %   disp    - Display a PSM object in the console
    %
    %
    % ==UTILITIES==
    % Utility methods that help the class run. They are not intended for
    % users and do not implement error checking.
    %
    % Estimate:
    %   estimate    - Run a forward model on inputs extracted from a state vector ensemble
    %
    % Utilities:
    %   name        - Return a name for a PSM object for use in error messages
    %   parseRows   - Process and error check the inputs to the "rows" command
    %
    % <a href="matlab:dash.doc('PSM.Interface')">Documentation Page</a>

    % Information about a forward model's codebase
    properties (Abstract, Constant)
        estimatesR;         % Whether the forward model can estimate R uncertainties
        description;        % A description of the forward model
        hasMemory;          % Whether the forward model maintains memory between time steps

        repository;         % The Github repository holding the code
        commit;             % The git commit for the version of the forward model supported by DASH
        commitComment;      % Details about the supported commit
    end

    properties (SetAccess = private)
        label_ = "";    % An optional label for the forward model
        hasRows;        % Whether the user provided state vector rows for the forward model 
        rows_;          % The state vector rows to use as input to the forward model
    end

    % Methods that individual PSMs must implement
    methods (Abstract)

        % PSM.Interface.estimate  Generate proxy estimate by running a forward model
        % ----------
        %   Y = <strong>obj.estimate</strong>(X)
        %   Generate proxy estimates by running a forward model on values
        %   from a state vector ensemble.
        %
        %   [Y, R] = <strong>obj.estimate</strong>(X)
        %   If supported, also estimate proxy uncertainties from the
        %   forward model.
        % ----------
        %   Inputs:
        %       X (numeric array [? x nMembers x nEvolving]): The values
        %           from a state vector ensemble needed to run the forward model
        %
        %   Outputs:
        %       Y (numeric matrix [1 x nMembers x nEvolving]): Proxy
        %           estimates generated by running the forward model
        %       R (numeric matrix [1 x nMembers x nEvolving]): Uncertainty
        %           estimates generated by running the forward model
        %
        % <a href="matlab:dash.doc('PSM.Interface.estimate')">Documentation Page</a>
        [Y, R] = estimate(obj, X);

        % PSM.Interface.rows  Indicate the state vector rows required to run a forward model
        % ----------
        %   obj = <strong>obj.rows</strong>(rows)
        %   Indicate the state vector row that should be used as input to
        %   the PSM when calling the "PSM.estimate" command. The input is a
        %   column vector with one element per slope/linear coefficient in 
        %   the forward model. Uses the same state vector rows for each 
        %   ensemble member and each ensemble in an evolving set.
        %
        %   obj = <strong>obj.rows</strong>(memberRows)
        %   Indicate which state vector rows to use for each ensemble member. This 
        %   syntax allows you to use different state vector rows for different
        %   ensemble members. The input is a matrix with one row per 
        %   required input and one column per ensemble member.
        %
        %   obj = <strong>obj.rows</strong>(evolvingRows)
        %   Indicate which state vector rows to use for different ensembles in an 
        %   evolving set. This syntax allows you to use different state vector rows
        %   for different ensembles in an evolving set. The input should be a 3D 
        %   array of either size [nInputs x 1 x nEvolving] or of size 
        %   [nInputs x nMembers x nEvolving]. If the second dimension has a size of 1,
        %   uses the same rows for all the ensemble members in a particular evolving
        %   ensemble. If the second dimension has a size of nMembers, allows you to
        %   use differents row for each ensemble member in each evolving ensemble.
        %
        %   rows = <strong>obj.rows</strong>
        %   Returns the current rows for the PSM object
        %
        %   obj = <strong>obj.rows</strong>('delete')
        %   Deletes any currently specified rows from the PSM object.
        % ----------
        %   Inputs:
        %       rows (column vector, linear indices [nInputs]): 
        %           The state vector rows that hold the variables required to run
        %           the PSM. Uses the same rows for all ensemble members and
        %           ensembles in an evolving set.
        %       memberRows (matrix, linear indices [nInputs x nMembers]): Indicates
        %           which state vector rows to use for each ensemble member. Should
        %           be a matrix with one row per input and one column per
        %           ensemble member. Uses the same rows for the ensemble members in
        %           different evolving ensembles.
        %       evolvingRows (3D array, linear indices [nInputs x 1|nMembers x nEvolving]):
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
        %       obj (scalar PSM object): The PSM with updated rows
        %       rows (linear indices, [nSlopes x 1|nMembers x 1|nEvolving]): The current
        %           rows for the PSM.
        %
        % <a href="matlab:dash.doc('PSM.Interface.rows')">Documentation Page</a>
        output = rows(obj, rows);
    end

    % Methods for all PSMs
    methods
        function[varargout] = label(obj, label)
            %% PSM.Interface.label  Return or set the label of a PSM object
            % ----------
            %   label = <strong>obj.label</strong>
            %   Returns the label of the current PSM object.
            %
            %   obj = <strong>obj.label</strong>(label)
            %   Applies a new label to the PSM object
            % ----------
            %   Inputs:
            %       label (string scalar): A new label for the PSM
            %
            %   Outputs:
            %       label (string scalar): The current label of the object
            %       obj (scalar PSM.Interface object): The object with an updated label.
            %
            % <a href="matlab:dash.doc('PSM.Interface.label')">Documentation Page</a>
            
            % Setup
            header = "DASH:PSM:label";
            dash.assert.scalarObj(obj, header);
            
            % Return current label
            if ~exist('label','var')
                varargout = {obj.label_};
            
            % Apply new label
            else
                obj.label_ = dash.assert.strflag(label, 'label', header);
                varargout = {obj};
            end
        end        
        function[name] = name(obj)
            %% PSM.Interface.name  Return a name for error messages
            % ----------
            %   name = <strong>obj.name</strong>
            %   Returns a name for the PSM for use in error messages. The
            %   name includes the type of PSM and the label if the PSM has
            %   a label.
            % ----------
            %   Outputs:
            %       name (string scalar): A name for the PSM for use in error messages
            %
            % <a href="matlab:dash.doc('PSM.Interface.name')">Documentation Page</a>

            % Get the type of PSM
            type = class(obj);
            type = type(5:end);
            
            % Unlabeled
            if strcmp(obj.label_, "")
                name = sprintf('The %s PSM', type);
            else
                name = sprintf('The "%s" %s PSM', type);
            end
        end  
        function[output] = parseRows(obj, rows, nRequired)
            %% PSM.Interface.parseRows  Parse rows for a PSM object
            % ----------
            %   obj = <strong>obj.parseRows</strong>(rows, nRequired)
            %   Error checks and records rows for a PSM object. Throws an error if the
            %   rows are not valid.
            %
            %   rows = <strong>obj.rows</strong>
            %   Returns the current rows of the PSM object.
            %
            %   obj = <strong>obj.rows</strong>('delete')
            %   Deletes any previously specified rows from the PSM object.
            % ----------
            %   Inputs:
            %       rows (numeric array [1 x nMembers x nEvolving]): The state vector
            %           rows that hold the inputs for the PSMs.
            %       nRequired (numeric scalar): The number of state vector
            %           rows required to run the PSM
            %
            %   Outputs:
            %       obj (scalar PSM object): The PSM with updated rows
            %       rows (numeric array [1 x nMembers x nEvolving]): The current rows
            %           for the PSM object.
            %
            % <a href="matlab:dash.doc('PSM.Interface.parseRows')">Documentation Page</a>

            % Get the header
            header = class(obj);
            header = replace(header, '.', ':');
            header = sprintf('DASH:%s', header);
            
            % Require a scalar PSM object
            try
                dash.assert.scalarObj(obj, header);
            catch ME
                id = ME.identifier;
                message = replace(ME.message, "parseRows", "rows");
                ME = MException(id, '%s', message);
                throwAsCaller(ME);
            end
            
            % Return values
            if ~exist('rows', 'var')
                output = obj.rows_;
            
            % Delete
            elseif dash.is.strflag(rows) && strcmpi(rows, 'delete')
                obj.rows_ = [];
                obj.hasRows = false;
                output = obj;
            
            % Set rows. Error check rows
            else
                try
                    dash.assert.blockTypeSize(rows, 'numeric', [], 'rows', header);
                    dash.assert.positiveIntegers(rows, 'rows', header);
            
                    % Check the number of rows
                    nRows = size(rows, 1);
                    if nRows ~= nRequired
                        id = sprintf('%s:wrongNumberOfRows', header);
                        error(id, ['%s requires %.f rows to run, but the "rows" input ',...
                            'has %.f rows instead.'], obj.name, nRequired, nRows);
                    end
            
                % Minimize error stacks
                catch ME
                    throwAsCaller(ME);
                end
            
                % Record the rows
                obj.rows_ = rows;
                obj.hasRows = true;
                output = obj;
            end    
        end
        function[] = disp(obj)
            %% PSM.Interface.disp  Display a PSM object in the console
            % ----------
            %   <strong>disp</strong>(obj)
            %   <strong>obj.disp</strong>
            %   Displays a PSM object in the console. Begins by displaying
            %   a link to the class documentation. If the object is scalar,
            %   displays the label (if there is one). Also displays the
            %   status of assigned state vector rows. Displays any model
            %   parameters.
            %
            %   If the object is an array, displays the array size. If any
            %   of the objects in the array have labels, displays the
            %   labels. Any object without a label is listed as "<no
            %   label>". If the array is empty, declares that the array is
            %   empty.
            % ----------
            %   Inputs:
            %       obj (PSM object): The PSM object to display in the console
            %
            %   Prints:
            %       Displays the object in the console.
            %
            % <a href="matlab:dash.doc('PSM.Interface.disp')">Documentation Page</a>
            
            % Class documentation link
            type = class(obj);
            link = sprintf('<a href="matlab:dash.doc(''%s'')">%s PSM</a>', type, type(5:end));
            
            % If not scalar, display array size
            if ~isscalar(obj)
                info = dash.string.nonscalarObj(obj, link);
                fprintf(info);

                % Exit if empty
                if isempty(obj)
                    return
                end

                % Collect labels
                labels = strings(size(obj));
                for k = 1:numel(obj)
                    labels(k) = obj(k).label_;
                end
                
                % Display labels
                unlabeled = strcmp(labels, "");
                if ~all(unlabeled, 'all')
                    fprintf('    Labels:\n');
                    labels(unlabeled) = "<no label>";
                    if ismatrix(labels)
                        fprintf('\n');
                    end
                    disp(labels);
                end

            % Scalar object, start with title
            else
                fprintf('%s with properties:\n\n', link);

                % Label
                pad = '';
                if ~strcmp(obj.label_, "")
                    fprintf('    Label: %s\n', obj.label);
                    pad = ' ';
                end
                
                % Rows
                if isempty(obj.rows_)
                    details = 'none';
                else
                    details = 'set';
                end
                fprintf('%s    Rows: %s\n', pad, details);
                [nMembers, nEvolving] = size(obj.rows_, 2:3);
                if nMembers>1
                    fprintf('%s\t\tFor %.f ensemble members\n', pad, nMembers);
                end
                if nEvolving>1
                    fprintf('%s\t\tFor %.f evolving ensembles\n', pad, nEvolving);
                end
                fprintf('\n');

                % Get parameter fields
                interfaceProps = properties('PSM.Interface');
                objProps = properties(obj);
                isparameter = ~ismember(objProps, interfaceProps);
                parameterNames = objProps(isparameter);

                % Build and display parameter structure
                s = struct;
                for p = 1:numel(parameterNames)
                    name = parameterNames{p};
                    s.(name) = obj.(name);
                end
                fprintf('    Parameters:\n');
                disp(s);
            end
        end
    end

end