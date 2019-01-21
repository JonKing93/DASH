%% Creates a custom structure that stores design parameters for state
% vector variables.
%
% design = stateDesign( designName )
% Initializes a state vector design with no variables and an identifying
% name.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
classdef stateDesign
    
    properties
        % State vector properties
        name;  % An identifier for the state vector.
        
        % Variable properties
        var;  % The array of variable designs
        varName;        % The variable names. Used for indexing.
        
        % Coupler properties
        isCoupled;  % Whether ensemble indices are synced.
        defCouple;  % Whether the variable should be coupled by default
        
        % Synced indices
        syncState;   % Whether state indices are synced
        syncSeq;   % Whether sequence indices are synced
        syncMean;  % Whether mean indices are synced
    end
    
    methods
        %% Constructor
        function obj = stateDesign( name )
            % Set the name
            obj.name = name;
            
            % Initialize logical arrays as logical
            obj.isCoupled = logical([]);
            obj.defCouple = logical([]);
            
            obj.syncState = logical([]);
            obj.syncSeq = logical([]);
            obj.syncMean = logical([]);
        end
    end
end