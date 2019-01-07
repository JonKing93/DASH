%% This is a custom structure that stores an array of variable designs and 
% allows indexing by variable name.
classdef stateDesign < handle
    
    properties
        varDesign;  % The array of variable designs
        var;        % The indexing
    end
    
    methods
        % Constructor
        function obj = stateDesign( varDesign, var )
            obj.varDesign = varDesign;
            obj.var = var;
        end
        
        % Adds another variable
        function[obj] = addVar( obj, varDesign, var )
            obj.varDesign = [obj.varDesign; varDesign];
            obj.var = [obj.var; var];
        end 
    end
end