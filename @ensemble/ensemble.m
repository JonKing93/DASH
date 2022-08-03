classdef ensemble
    %% ensemble  Manipulate and load saved state vector ensembles
    % ----------
    %   The ensemble class implements objects that allow users to interact 
    %   with a saved state vector ensemble, while minimizing the amount of
    %   data that is actually loaded into memory. To that end, the class
    %   includes methods that allow users to load select variables and
    %   ensemble members, rather than all the data stored in a .ens file.
    %   The ensemble class also implements evolving ensembles, and lets
    %   users select saved ensemble members to use in different ensembles
    %   of an evolving set. 
    % 
    %   Ensemble objects can be provided to other commands in the DASH
    %   toolbox, such as "PSM.estimate" and "kalmanFilter.prior". This
    %   allows these methods to utilize values in a saved state vector
    %   ensemble, without requiring users to load the ensembles into
    %   memory. These other commands include various memory optimizations
    %   so that even very large ensembles can be used to estimate proxies
    %   or used for assimilation.
    %
    %   The following is an outline for using the ensemble class.
    %     0. Use "stateVector.build" with the 'file' option to save a state
    %        vector ensemble in a .ens file.
    %     1. Use the "ensemble" command to create an ensemble object for
    %        the .ens file.
    %     2. Use the "useVariables" command to select the state vector
    %        variables required for a particular task.
    %     3. Use "useMembers", "static", and/or "evolving" to implement
    %        static or evolving ensembles with particular members
    %     4. Use "load" to load the selected variables, ensemble members,
    %        or ensembles in an evolving set. Use "loadGrid" to load a
    %        variable and regrid it from a state vector to a gridded
    %        dataset. Use "loadRows" to load specific state vector rows.
    %
    %   The class also includes various methods that return information
    %   about the state vector ensemble. Among others, the "variables", 
    %   "length", "members", "label", and "evolvingLabels" commands can all
    %   help to facilitate workflows.
    % ----------
    % ensemble Methods:
    %
    % **KEY METHODS**
    % The following methods are among the most essential for users
    %
    %   ensemble                - Create an ensemble object for a saved state vector ensemble
    %   useVariables            - Use a subset of saved variables
    %   useMembers              - Use a subset of saved ensemble members
    %   evolving                - Implement an evolving ensemble
    %   metadata                - Return the metadata for an ensemble object
    %   load                    - Load portions of a state vector ensemble into memory
    %   loadGrid                - Load a variable in a state vector ensemble as a gridded field
    %
    %
    % *ALL USER METHODS*
    % The complete list of methods for users.
    %
    % Create:
    %   ensemble                - Create an ensemble object for a saved state vector ensemble
    %   label                   - Set or return a label for an ensemble object
    %
    % Subset:
    %   useVariables            - Use a subset of saved variables
    %   useMembers              - Use a subset of saved ensemble members
    %
    % Design:
    %   static                  - Implement a static ensemble
    %   evolving                - Implement an evolving ensemble
    %   evolvingLabels          - Label the different ensembles in an evolving ensemble
    %
    % Metadata:
    %   metadata                - Return the ensembleMetadata object for an ensemble
    %
    % Load:
    %   load                    - Loads a state vector ensemble into memory
    %   loadGrid                - Load a variable in a state vector ensemble as a gridded fields
    %   loadRows                - Loads specific rows of a state vector ensemble
    %
    % Information:
    %   length                  - Return the state vector length of an ensemble and its variables
    %   variables               - List the variables used in an ensemble
    %   members                 - List the ensemble members used in an ensemble
    %   info                    - Return information about an ensemble as a struct
    %
    % Sizes:
    %   nRows                   - Return the number of state vector rows for one or more ensemble objects
    %   nVariables              - Return the number of state vector variables for one or more ensemble objects
    %   nMembers                - Return the number of ensemble members for one or more ensemble objects
    %   nEvolving               - Return the number of ensembles implemented by static or evolving ensemble objects
    %
    % Add members:
    %   addMembers              - Add more members to a saved state vector ensemble
    %   update                  - Update an ensemble object to include new members added to a .ens file
    %
    % Console display:
    %   disp                    - Displays an ensemble object in the console
    %
    %
    % ==Utility Methods==
    % Utility methods that help the class run. These do not implement error
    % checking and are not intended for users.
    %
    % Assertions:
    %   assertEvolvingMembers   - Throw error if input is not a set of ensemble members for an evolving ensemble
    %   assertStaticMembers     - Throw error if input is not ensemble members for a static ensemble
    %
    % Indices:
    %   variableIndices         - Parse variables and return indices in state vector
    %   evolvingIndices         - Parse ensembles and return indices in the evolving set
    %
    % Console Display
    %   dispEvolving            - Display the labels of evolving ensembles in the console
    %   dispVariables           - Display the names and lengths of variables in an ensemble
    %
    % Misc:
    %   name                    - Return a name for use in error messages
    %   parseScope              - Parse scope inputs
    %   validateMatfile         - Check .ens file is valid and unaltered
    %
    % Unit Tests:
    %   tests                   - Unit tests for the ensemble class
    %
    % <a href="matlab:dash.doc('ensemble')">Documentation Page</a>

    properties (SetAccess = private)
        %% General

        file = strings(0,1);            % The .ens file associated with the object
        label_ = "";                    % An identifying label for the ensemble
        metadata_;                      % The ensembleMetadata object for the saved ensemble

        %% Variables

        variables_ = strings(0,1);      % The names of the variables in the .ens file
        use = true(0,1);                % Whether each variable is being used by the ensemble object
        lengths = NaN(0,1);             % The number of state vector rows for each variable

        %% Members

        totalMembers = NaN;             % The total number of members saved in the .ens file
        members_ = [];                  % The members being used by the ensemble object
        isevolving = false;             % Whether the object implements an evolving ensemble
        evolvingLabels_ = "";           % Labels for evolving ensembles

    end

    methods
        
        % General
        varargout = label(obj, label);
        name = name(obj);

        % Sizes
        nRows = nRows(obj, scope);
        nVariables = nVariables(obj, scope);
        nMembers = nMembers(obj, scope);
        nEvolving = nEvolving(obj, scope);

        % Variables
        obj = useVariables(obj, variables, scope);
        variableNames = variables(obj, variables, scope);
        lengths = length(obj, variables, scope);
        v = variableIndices(obj, variables, scope, header);

        % Members
        obj = useMembers(obj, varargin);
        members = members(obj, ensembles);

        % Static Ensembles
        obj = static(obj, members);
        members = assertStaticMembers(obj, members, name, header);

        % Evolving Ensembles
        obj = evolving(obj, varargin);
        varargout = evolvingLabels(obj, varargin);
        e = evolvingIndices(obj, ensembles, allowRepeats, header);
        members = assertEvolvingMembers(obj, members, nRows, nCols, name, header);

        % Metadata
        metadata = metadata(obj, ensembles);

        % Load
        [X, metadata] = load(obj, ensembles);
        [X, members, labels] = loadRows(obj, rows, ensembles);
        [X, metadata, members, labels] = loadGrid(obj, variable, ensembles);

        % Matfile interactions
        obj = addMembers(obj, nMembers, strict);
        obj = update(obj);
        [m, metadata, precision] = validateMatfile(obj, header);

        % Console display
        disp(obj, showVariables, showEvolving);
        dispVariables(obj, showFile);
        dispEvolving(obj);

    end

    methods (Static)
        useFile = parseScope(scope, header);
        tests;
    end

    % Constructor
    methods
        function[obj] = ensemble(filenames, labels)
            %% ensemble.ensemble  Create an ensemble object for a saved state vector ensemble
            % ----------
            %   obj = ensemble(filenames)
            %   Creates an array of ensemble objects for the specified .ens files. Each
            %   ensemble object can be used to manipulate and load subsets of a saved
            %   ensemble while limiting use of computer memory. The label of each
            %   ensemble object will match the label of the stateVector object used
            %   to build the ensemble.
            %
            %   obj = ensemble(filenames, labels)
            %   Specify the labels to apply to each ensemble object.
            % ----------
            %   Inputs:
            %       filenames (string array | cellstring array | char row vector): The
            %           names of the .ens files to build ensemble objects for
            %       labels (string array): Labels for each of the elements in the
            %           array of ensemble objects. Must have a size that matches the
            %           number of input filenames.
            %
            %   Outputs:
            %       obj (ensemble object array): An array of ensemble objects for the
            %           specified .ens files. The size will match the number of
            %           provided filenames.
            %
            % <a href="matlab:dash.doc('ensemble.ensemble')">Documentation Page</a>

            % Header
            header = "DASH:ensemble";

            % Error check the file names
            filenames = dash.assert.string(filenames, 'filenames', header);
            if isempty(filenames)
                id = sprintf('%s:emptyFilename', header);
                error(id, 'filename cannot be empty');
            end
            siz = size(filenames);

            % Default and error check labels
            if ~exist('labels','var')
                haveLabels = false;
            else
                haveLabels = true;
                labels = dash.assert.string(labels, 'labels', header);

                % Check matching size
                if ~isequal(size(labels), siz)
                    id = sprintf('%s:labelsDifferentSize', header);
                    error(id, ['The size of the "labels" input (%s) is different than the size of the ',...
                        '"filenames" input (%s).'], dash.string.size(size(labels)), dash.string.size(siz));
                end
            end

            % Preallocate ensemble array
            obj = repmat(obj, siz);

            % Get unique files and associated objects
            [uniqueFiles, ~, whichObj] = unique(filenames, 'stable');
            nUniqueFiles = numel(uniqueFiles);

            % Build the ensemble object for each file
            try
                for f = 1:nUniqueFiles
                    file = uniqueFiles(f);
                    usesFile = whichObj==f;
                    k = find(usesFile, 1);

                    % Check and update file path
                    file = dash.assert.fileExists(file, '.ens', header);
                    obj(k).file = dash.file.urlSeparators(file);

                    % Validate matfile contents. Build ensembleMetadata
                    try
                        [~, metadata] = obj(k).validateMatfile(header);
                    catch ME
                        throw(ME);
                    end
                    
                    % Initialize ensemble properties
                    obj(k).label_ = metadata.label;
                    obj(k).variables_ = metadata.variables;
                    obj(k).use = true(size(obj(k).variables_));
                    obj(k).lengths = metadata.length(-1);
                    obj(k).totalMembers = metadata.nMembers;
                    obj(k).members_ = (1:obj(k).totalMembers)';
                    obj(k).metadata_ = metadata;

                    % Fill all objects that use the file
                    obj(usesFile) = obj(k);
                end

            % Informative error if failed. Adjust message for scalar vs array
            catch cause
                if isscalar(obj)
                    throw(cause);
                else
                    id = sprintf('%s:couldNotBuildEnsemble', header);
                    ME = MException(id, 'Could not build the ensemble object for filename %.f (%s).', k, file);
                    ME = addCause(ME, cause);
                    throw(ME);
                end
            end

            % Apply user labels
            if haveLabels
                labels = num2cell(labels);
                [obj.label_] = labels{:};
            end
        end
    end
end