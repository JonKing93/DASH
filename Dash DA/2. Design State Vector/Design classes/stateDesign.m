%% This is a custom structure that stores an array of variable designs and 
% allows indexing by variable name.
classdef stateDesign < handle
    
    properties
        varDesign;  % The array of variable designs
        var;        % The variable names. Used for indexing.
    end
    
    methods
        %% Error checks the inputs
        function[] = errorCheck( ~, varDesign, var )
            if ~isa(varDesign, 'varDesign')
                error('varDesign must be of the ''varDesign'' class.');
            elseif ~(isstring(var) && isscalar(var)) && ~(ischar(var) && isvector(var))
                error('var must be a string.');
            end
        end 
        
        %% Constructor
        function obj = stateDesign( varDesign, var )
            obj.errorCheck(varDesign, var);
            obj.varDesign = varDesign;
            obj.var = {var};
        end
        
        %% Adds another variable
        function[obj] = addVar( obj, varDesign, var )
            
            % Error check
            obj.errorCheck(varDesign, var);
            
            % Check that the variable is not a repeat
            if ismember(var, obj.var)
                error('Cannot repeat variable names.');
            end
            
            % Add the variable
            obj.varDesign = [obj.varDesign; varDesign];
            obj.var = [obj.var; {var}];
        end 
    end
end