classdef ensemble
    
    properties
        file; % The .ens file associated with the object
        
        hasnan;
        meta;
        stateVector;
        
        members; % Which ensemble members to load
        v; % The indices of the variables to load.
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
            
            % Check the input is a file name
            file = dash.assertStrFlag(filename, "filename");
            obj.file = dash.checkFileExists(file);
            
            % Load the data from the .ens file
            try
                m = matfile(obj.file);
            catch
                error('Could not load ensemble data from "%s". It may not be a .ens file. If it is a .ens file, it may have become corrupted.', obj.file);
            end
            
            % Ensure all fields are present
            required = ["X","hasnan","meta","stateVector"];
            varNames = who(m);
            if any(~ismember(required, varNames))
                bad = find(~ismember(required, varNames),1);
                error('File "%s" does not contain the "%s" field.', obj.file, required(bad));
            end
            
            % Update properties
            obj.hasnan = m.hasnan;
            obj.meta = m.meta;
            obj.stateVector = m.stateVector;
            
            % Load everything by default
            obj.members = (1:obj.meta.nEns)';
            obj.v = (1:numel(obj.meta.variableNames))';
        end
    end
            
    % User methods
    methods
        add(obj, nAdd, showprogress)
        load(obj);
        loadGrids(obj);
        obj = loadMembers(obj, members);
        obj = loadVariables(obj, variables);
        
        variableNames(obj);
        info(obj);
    end
    
end