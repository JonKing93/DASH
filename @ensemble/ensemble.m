classdef ensemble
    %% Manages a state vector ensemble saved in a .ens file.
    %
    % ensemble Methods:
    %   load - Loads a state vector ensemble from a .ens file
    %   loadGrids - Load gridded climate variables instead of state vectors
    %   useMembers - Specify which ensemble members to load.
    %   useVariables - Specify which state vector variables to load.
    %   loadedMetadata - Return an ensembleMetadata object for the data that
    %                    will be loaded.
    %   add - Add more members to the ensemble.
    %   variableNames - List the variables in the state vector ensemble
    %   info - Return a summary of the data saved in the .ens file and the
    %          data that will be loaded.
    
    properties (SetAccess = private)
        file; % The .ens file associated with the object
        name; % The name of the ensemble object
        
        has_nan; % Whether a variable has NaN in an ensemble member
        metadata; % Ensemble metadata object for the saved state vector ensemble
        stateVector; % The stateVector object used to build the ensemble
        
        members; % Which ensemble members to load
        variables; % The names of the variables to load
    end
    
    % Constructor
    methods
        function obj = ensemble(filename, name)
            %% Creates a new ensemble object
            %
            % obj = ensemble(filename)
            % Finds a .ens file with the specified name on the active path
            % and returns an associated ensemble object.
            %
            % obj = ensemble(fullname)
            % Returns an ensemble object for a .ens file with the specified
            % full file path.
            %
            % obj = ensemble(filename, name)
            % Provides an identifying name for the ensemble object.
            %
            % ----- Inputs -----
            %
            % filename: The name of a .ens file on the active path. A string.
            %
            % fullname: The full file path to a .ens file. A string.
            %
            % name: An identifying name for the ensemble object. A string.
            %
            % ----- Outputs -----
            %
            % obj: An ensemble object for the specified .ens file.
            
            % Error check file name. Get matfile properties
            filename = dash.assertStrFlag(filename, "filename");
            obj.file = dash.checkFileExists(filename);
            obj = obj.update;
            
            % Members and variables are unspecified.
            obj.members = [];
            obj.variables = [];

            % Name
            if exist('name','var')
                obj.name = dash.assertStrFlag(name,'name');
            end
        end
    end
        
    % Object utilities
    methods
        ens = buildMatfile(obj, writable);
        obj = update(obj, ens);
        [members, v] = loadSettings(obj);
    end
    
    % User methods
    methods
        obj = add(obj, nAdd, showprogress)
        [X, meta] = load(obj);
        meta = loadedMetadata(obj, varNames, members);
        s = loadGrids(obj);
        obj = useMembers(obj, members);
        obj = useVariables(obj, variables);
        varNames = variableNames(obj);
        s = info(obj);
        nanMembers = hasnan(obj, varNames);
        obj = rename(obj, newName);
    end
end