classdef ensemble
    
    
    properties
        file; % The .ens file associated with the 
        members; % Which ensemble members to load
        variables; % Which variables to load
    end
    
    methods
        load(obj);
        loadGrids(obj);
        loadMembers(obj, members);
        loadVariables(obj, variables);
    end
    
end
        
        
        