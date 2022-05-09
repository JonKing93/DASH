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
        members = members(obj, ensembles);
        obj = useMembers(obj, varargin);

        % Static Ensembles
        obj = static(obj, members);
        members = assertStaticMembers(obj, members, name, header);

        % Evolving Ensembles
        obj = evolving(obj, varargin);
        varargout = evolvingLabels(obj, varargin);
        e = evolvingIndices(obj, ensembles, allowRepeats, header);
        members = assertEvolvingMembers(obj, members, nRows, nCols, name, header);

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
        function[obj] = ensemble(files, label)

            % Optionally label the object
            if exist('label','var')
                try
                    obj = obj.label(label);
                catch ME
                    throw(ME);
                end
            end

            % Create some placeholder values
            obj.file = "C://users/test/filename.ens";
            obj.variables_ = ["Temp";"Precip";"SLP";"X"];
            obj.use = true(4,1);
            obj.lengths = [100;5;219;1];

            obj.totalMembers = 1156;
            obj.members_ = (1:obj.totalMembers)';
        
        end
    end



%     % Construction
%     methods
%         function[obj] = ensemble(files)
% %% ensemble.ensemble  Create an ensemble object for a saved state vector ensemble
% % ----------
% %   obj = ensemble(files)
% %   Creates an ensemble object or array of ensemble objects for
% %   a state vector ensembles saved in .ens files. The ensemble
% %   objects can be used to manipulate and load subsets of the
% %   saved ensembles while limiting use of computer memory.
% %
% %   obj = ensemble(files, labels)
% %   Also labels the ensemble objects. 
% % ----------
% %   Inputs:
% %       files (string array): The file paths to one or more .ens files.
% %           Adds a ".ens" extension if a file cannot be found and lacks
% %           the extension.
% %       labels (string, scalar | array [size(files)]): A set of labels
% %           for the ensemble objects. Should have the same size as the
% %           "files" input. Alternatively, use a string scalar or char row
% %           vector to apply the same label to all the objects.
% %
% %   Outputs:
% %       obj (ensemble array): An array of ensemble objects for the
% %       specified .ens files.
% %
% % <a href="matlab:dash.doc('ensemble.ensemble')">Documentation Page</a>
% 
% % Error header
% header = "DASH:ensemble";
% 
% % Error check filename
% files = dash.assert.string(files);
% if isempty(files)
%     id = sprintf('%s:emptyFilenames', header);
%     error(id, 'file names cannot be empty');
% end
% 
% % If scalar, build the ensemble object
% if isscalar(files)
%     file = dash.assert.fileExists(files, '.ens', header);
%     obj.file = dash.file.urlSeparators(file);
% 
%     % Get a matfile object for the ensemble
%     reset = dash.warning.state('off', 'MATLAB:load:variableNotFound'); %#ok<NASGU> 
%     try
%         m = matfile(file);
%     catch
%         id = sprintf('%s:couldNotLoad', header);
%         error(id, ['Could not load data from file:\n\t%s\n',...
%             'It may not be a valid .ens file.'], file);
%     end
% 
%     % Ensure required fields are in the file
%     requiredFields = ["X","stateVector"];
%     loadedFields = fieldnames(m);
%     [loaded, loc] = ismember(requiredFields, loadedFields);
%     if ~all(loaded)
%         missing = find(loc==0,1);
%         missing = requiredFields(missing);
%         id = sprintf('%s:missingField', header);
%         error(id, ['The file:\n\t%s\nis missing the "%s" field. It may not ',...
%             'be a valid .ens file.'], file, missing);
%     end
% 
%     % Check that the data matrix is valid. Get data size.
%     info = whos(m, 'X', 'stateVector');
%     if ~ismember(info(1).class, ["single","double"])
%         invalidTypeError;
%     elseif numel(info(1).size)~=2
%         Xmustbematrix
%     elseif any(info(1).size==0)
%         XcannotBeEmpty
%     end
%     Xsize = info(1).size;
% 
%     % Load the ensemble metadata, error check, etc.
%     warning('unfinished');

end






       



