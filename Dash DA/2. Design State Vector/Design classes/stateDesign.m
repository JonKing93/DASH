%% This is a custom structure that stores an array of variable designs and 
% allows indexing by variable name.
classdef stateDesign
    
    properties
        % State vector properties
        name;  % An identifier for the state vector.
        
        % Variable properties
        var;  % The array of variable designs
        varName;        % The variable names. Used for indexing.
        
        % Coupler properties
        isCoupled;  % Whether ensemble indices are coupled.
        coupleState;   % Whether state indices are coupled
        coupleSeq;   % Whether sequence indices are coupled
        coupleMean;  % Whether mean indices are coupled
    end
    
    methods
        %% Constructor
        function obj = stateDesign( name )
            % Set the name
            obj.name = name;
        end
        
        %% Adds another variable
        function[obj] = addVar( obj, file, name )
            
            % Get the name if not specified
            if ~exist('name','var')
                meta = metaGridfile( file );
                name = meta.var;
            end
            
            % Check that the variable is not a repeat
            if ismember(name, obj.var)
                error('Cannot repeat variable names.');
            end
            
            % Initialize the varDesign
            newVar = varDesign(file, name);           
            
            % Add the variable
            obj.var = [obj.var; newVar];
            obj.varName = [obj.var; name];
            
            % Adds coupler indices
            obj.isCoupled(end+1,end+1) = false;
            obj.coupleState(end+1,end+1) = false;
            obj.coupleSeq(end+1,end+1) = false;
            obj.coupleMean(end+1,end+1) = false;
        end 
    end
end