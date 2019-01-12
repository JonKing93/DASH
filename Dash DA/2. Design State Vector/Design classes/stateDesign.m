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
    end
end