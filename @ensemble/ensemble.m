classdef ensemble
    
    properties (SetAccess = private)
        file; % The .ens file associated with the object
        
        hasnan; % Whether a variable has NaN in an ensemble member
        meta; % Ensemble metadata object for the saved state vector ensemble
        stateVector; % The stateVector object used to build the ensemble
        
        members; % Which ensemble members to load
        variables; % The names of the variables to load
    end
    
    % Constructor
    methods
        function obj = ensemble(filename)
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
            % ----- Inputs -----
            %
            % filename: The name of a .ens file on the active path. A string.
            %
            % fullname: The full file path to a .ens file. A string.
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
        end
    end
        
    % Object utilities
    methods
        ens = buildMatfile(obj);
        obj = update(obj, ens);
        [members, v] = loadSettings(obj);
    end
    
    % User methods
    methods
        add(obj, nAdd, showprogress)
        [X, meta] = load(obj);
        loadGrids(obj);
        obj = useMembers(obj, members);
        obj = useVariables(obj, variables);
        varNames = variableNames(obj);
        s = info(obj);
    end
end