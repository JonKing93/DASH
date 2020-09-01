classdef stateVectorVariable
    % This class implements a custom structure to hold design parameters
    % for a variable in a state vector.
    
    properties (SetAccess = private)
        % Set by constructor
        name;  % The identifying name of the variable
        file; % Name of the .grid file
        dims; % .grid file dimension order
        gridSize; % .grid file size

        % Design
        stateSize; % Length of each dimension in the state vector
        ensSize; % Number of possible ensemble members
        isState; % Whether a dimension is a state dimension
        indices; % State indices or ensemble reference indices, as appropriate
        
        % Sequences
        % size;
        seqIndices; % Sequence indices
        seqMetadata; % Sequence metadata
        
        % Means
        takeMean; % Whether to take a mean over a dimension
        meanSize; % Number of elements used in the mean along each dimension
        omitnan; % Whether to exclude NaN values 
        mean_Indices; % Mean indices for ensemble dimensions
        
        % Weighted means
        hasWeights; % Whether the dimension has weights
        weightCell; % Weights for each dimension
    end
    
    % Constructor
    methods
        function obj = stateVectorVariable(varName, file)
            % Creates a new stateVectorVariable object for data in a .grid
            % file.
            %
            % obj = stateVectorVariable(varName, file);
            %
            % ----- Inputs -----
            %
            % varName: The name of the variable. A string.
            %
            % file: The name of the .grid file that holds the variable
            %
            % ----- Outputs -----
            %
            % obj: The new stateVectorVariable object
            
            % Error check
            varName = dash.assertStrFlag(varName, 'varName');
            file = dash.assertStrFlag(file, 'file');
            file = dash.checkFileExists(file);
            
            % Name. Use string internally
            obj.name = string(varName);
            
            % Get gridfile properties
            grid = gridfile(file);
            obj.file = grid.file;
            obj.dims = grid.dims;
            obj.gridSize = grid.size;
            
            % Initialize dimension properties
            nDims = numel(obj.dims);
            obj.stateSize = NaN(1, nDims);
            obj.ensSize = NaN(1, nDims);
            obj.isState = true(1, nDims);
            obj.indices = cell(1, nDims);
            
            obj.seqIndices = cell(1, nDims);
            obj.seqMetadata = cell(1, nDims);
            
            obj.takeMean = false(1, nDims);
            obj = obj.resetMeans;
            
            % Initialize all dimensions as state dimensions
            for d = 1:numel(obj.dims)
                obj = obj.design(obj.dims(d), 'state');
            end
        end
    end
    
    % Object utilities
    methods
        [d, dims] = checkDimensions(obj, dims);
        assertEnsembleIndices(obj, indices, d, name);
        obj = trim(obj);
    end
    
    % Static utilities
    methods (Static)
        [input, wasCell] = parseInputCell(input, nDims, name);
        input = parseLogicalString(input, nDims, logicalName, stringName, allowedStrings, lastTrue, name);
    end
    
    % Interface methods
    methods
        obj = sequence(obj, dims, indices, metadata);
        obj = mean(obj, dims, indices, omitnan);
        obj = weightedMean(obj, dims, weights);
        obj = resetMeans(obj);
        obj = design(obj, dims, type, indices);
        
        info(obj);
        obj = rename(obj, newName);
        X = buildEnsemble(obj, member, sources);
    end
end
        