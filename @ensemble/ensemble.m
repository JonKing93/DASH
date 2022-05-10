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

        % Console display
        disp(obj, showVariables, showEvolving);
        dispVariables(obj, showFile);
        dispEvolving(obj);

    end

    methods (Static)
        useFile = parseScope(scope, header);
        tests;
    end

%     % Constructor
%     methods
%         function[obj] = ensemble(files, label)
% 
%             % Optionally label the object
%             if exist('label','var')
%                 try
%                     obj = obj.label(label);
%                 catch ME
%                     throw(ME);
%                 end
%             end
% 
%             % Create some placeholder values
%             obj.file = "C://users/test/filename.ens";
%             obj.variables_ = ["Temp";"Precip";"SLP";"X"];
%             obj.use = true(4,1);
%             obj.lengths = [100;5;219;1];
% 
%             obj.totalMembers = 1156;
%             obj.members_ = (1:obj.totalMembers)';
%         
%         end
%     end

    % Constructor
    methods
        function[obj] = ensemble(filenames, labels)
            %% ensemble.ensemble  Create an ensemble object for a saved state vector ensemble
            % ----------
            %   obj = ensemble(filename)
            %   Creates an ensemble object for the ensemble saved in a .ens file. The
            %   ensemble object can be used to manipulate and load subsets of the saved
            %   ensemble while limiting use of computer memory.
            %
            %   obj = ensemble(filenames)
            %   Creates an array of ensemble objects for the specified .ens files. 
            %
            %   obj = ensemble(..., labels)
            %   Also labels the new ensemble objects.
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
                labels = strings(size(filenames));
            else
                labels = dash.assert.string(labels, 'labels', header);

                % Check matching size
                labelSize = size(labels);
                if ~isequal(labelSize, siz)
                    id = sprintf('%s:labelsDifferentSize', header);
                    error(id, ['The size of the "labels" input (%s) is different than the size of the ',...
                        '"filenames" input (%s).'], dash.string.size(labelSize), dash.string.size(siz));
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

                    % Validate matfile contents. Get state vector
                    m = obj(k).validateMatfile;
                    sv = m.stateVector;

                    % Initialize variables, members, and metadata
                    obj(k).variables_ = sv.variables;
                    obj(k).use = true(size(obj.variables_));
                    obj(k).lengths = sv.length(-1);
                    obj(k).totalMembers = sv.members;
                    obj(k).members_ = (1:obj.totalMembers)';
                    obj(k).metadata_ = ensembleMetadata(sv);

                    % Fill all objects that use the file
                    obj(usesFile) = obj(k);
                end

            % Informative error if failed. Tweak message for scalar vs array
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

            % Apply labels
            labels = num2cell(labels);
            [obj.label_] = labels{:};
        end
    end
end