classdef ensemble
    
    
    properties
        file; % The .ens file associated with the 
        
        hasnan;
        meta;
        stateVector;
        
        members; % Which ensemble members to load
        variables; % Which variables to load
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
            
            warning('Constructor needs error checking');
            m = matfile(obj.file);
            obj.hasnan = m.hasnan;
            obj.meta = m.meta;
            obj.stateVector = m.stateVector;
        end
    end
            
            
            
            
            
            
            
    
    methods
        add(obj, nAdd, showprogress)
        load(obj);
        loadGrids(obj);
        loadMembers(obj, members);
        loadVariables(obj, variables);
    end
    
end
        
        
        