classdef ensemble
    
    
    properties
        file;
        members; % Which ensemble members to load
        variables; % Which variables to load
    end
    
    
    methods
        add(obj, nAdd);
        load(obj, members, rows);
    end
    
end
        
        
        