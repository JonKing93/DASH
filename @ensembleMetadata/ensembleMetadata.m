classdef ensembleMetadata
    % Manages metadata for an ensemble
    
    properties
        ensembleName; % Name of the ensemble
        vectorName; % Name of the state vector template
        
        variableNames; % Names of each metadata
        varLimit; % The limit of each variable down the state vector
        stateMeta; % Dimensional metadata down the state vector for each variable
        ensMeta; % Dimensional metadata across the ensemble for each variable
    end
    
    % Constructor
    methods
        function obj = ensembleMetadata(sv)
            % Creates an ensembleMetadata object for a stateVector,
            % ensemble, or .ens file.
            %
            % obj = ensembleMetadata(sv)
            % Creates an ensembleMetadata object for a state vector.
            %
            % ----- Inputs -----
            %
            % sv: A stateVector object
            %
            % ----- Outputs -----
            %
            % obj: The ensembleMetadata object
            
            % Error check
            if ~isa(sv, 'stateVector') || ~isscalar(sv)
                error('sv must be a scalar stateVector object.');
            end
            
            % Names
            obj.ensembleName = string([]);
            obj.vectorName = sv.name;
            
            % Variable indexing
            obj.variableNames = sv.variableNames;
            obj.varLimit = sv.variableLimits;
            
            % Get the gridfile
    end
    
    % User methods
    methods
        regrid;
    end
    
end