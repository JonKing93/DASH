%% This is an array of variable designs that permits variable indexing for
% the larger state vector.
classdef stateDesign < handle
    
    properties
        varDesign;
        var;
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