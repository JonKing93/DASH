%% This is a custom structure that stores an array of variable designs and 
% allows indexing by variable name.
classdef stateDesign
    
    properties
        % State vector properties
        name;  % An identifier for the state vector.
        
        % Variable properties
        varDesign;  % The array of variable designs
        var;        % The variable names. Used for indexing.
        
        % Coupler properties
        isCoupled;  % Whether ensemble indices are coupled.
        coupleState;   % Whether state indices are coupled
        coupleSeq;   % Whether sequence indices are coupled
        coupleMean;  % Whether mean indices are coupled
    end
    
    methods
        %% Constructor
        function obj = stateDesign( varDesign, name )
            
            % Ensure we are storing a variable design
            if ~isa(varDesign, 'varDesign')
                error('varDesign must be of the ''varDesign'' class.');
            end
            
            % Store the name
            if exist('name','var')
                obj.name = name;
            end
            
            % Save the design and variable name
            obj.varDesign = varDesign;
            obj.var = varDesign.name;
            
            % Initialize the coupler properties.
            obj.isCoupled = false;
            obj.coupleState = false;
            obj.coupleSeq = false;
            obj.coupleMean = false;
        end
        
        %% Adds another variable
        function[obj] = addVar( obj, varDesign )
            
            % Ensure we are storing a variable design
            if ~isa(varDesign, 'varDesign')
                error('varDesign must be of the ''varDesign'' class.');
            end
            
            % Check that the variable is not a repeat
            if ismember(varDesign.name, obj.var)
                error('Cannot repeat variable names.');
            end
            
            % Add the variable
            obj.varDesign = [obj.varDesign; varDesign];
            obj.var = [obj.var; varDesign.name];
            
            % Adds coupler indices
            obj.isCoupled(end+1,end+1) = false;
            obj.coupleState(end+1,end+1) = false;
            obj.coupleSeq(end+1,end+1) = false;
            obj.coupleMean(end+1,end+1) = false;
        end 
    end
end