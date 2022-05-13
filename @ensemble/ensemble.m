classdef ensemble
    %% ensemble  Manipulate and load saved state vector ensembles
    % ----------
    %   Introduction
    % ----------
    % ensemble Methods:
    %
    % *ALL USER METHODS*
    % The complete list of methods for users.
    %
    % Create:
    %   ensemble        - Create an ensemble object for a saved state vector ensemble
    %   label           - Set or return a label for an ensemble object
    %
    % Subset:
    %   useVariables    - Use a subset of saved variables
    %   useMembers      - Use a subset of saved ensemble members
    %
    % Evolving ensembles:
    %   evolving        - Implement an evolving ensemble
    %   labelEvolving   - Label the different ensembles in an evolving ensemble
    %
    % Metadata:
    %   metadata        - Return the ensembleMetadata object for an ensemble
    %
    % Sizes:
    %   nRows           - Return the number of state vector rows for one or more ensemble objects
    %   nVariables      - Return the number of state vector variables for one or more ensemble objects
    %   nMembers        - Return the number of ensemble members for one or more ensemble objects
    %   nEnsembles      - Return the number of ensembles implemented by static or evolving ensemble objects
    %
    % Load:
    %   load            - Loads a state vector ensemble into memory
    %   loadGrids       - Loads the variables of a state vector ensemble as gridded fields
    %   loadRows        - Loads specific rows of a state vector ensemble
    %
    % Information:
    %   length          - Return the state vector length of an ensemble and its variables
    %   variables       - List the variables used in an ensemble
    %   members         - List the ensemble members used in an ensemble
    %   info            - Return information about an ensemble as a struct
    %
    % Add members:
    %   addMembers      - Add more members to a saved state vector ensemble
    %
    % Console display:
    %   disp            - Displays an ensemble object in the console
    %
    %
    % ==Utility Methods==
    %   
    % General:
    %   name            - Return a name for use in error messages

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
        X = loadRows(obj, scope);
        X = loadGrid(obj, variable, scope);

        % Matfile interactions
        obj = addMembers(obj, nMembers, strict);
        obj = update(obj);
        [m, metadata] = validateMatfile(obj, header);

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
            %   obj = ensemble(..., labels)
            %   Specify the labels to apply to each ensemble object.
            % ----------

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
                    [~, metadata] = obj(k).validateMatfile(header);
                    
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