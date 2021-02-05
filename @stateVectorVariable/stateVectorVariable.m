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
        
        % Metadata
        hasMetadata;
        metadata;
        convert;
        convertFunction;
        convertArgs;
    end
    
    properties (Hidden, Constant)
        infoFields = {'name','gridfile','stateSize','possibleMembers',...
            'dimensions','stateDimensions','ensembleDimensions','singletonDimensions'};
        loadSettingFields = {'siz','d','meanDims','nanflag','indices','addIndices'};
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
            obj.meanSize = NaN(1, nDims);
            obj.omitnan = false(1, nDims);
            obj.mean_Indices = cell(1, nDims);
            
            obj.hasWeights = false(1, nDims);
            obj.weightCell = cell(1, nDims);
            
            obj.hasMetadata = false(1, nDims);
            obj.metadata = cell(1, nDims);
            obj.convert = false(1, nDims);
            obj.convertFunction = cell(1, nDims);
            obj.convertArgs = cell(1, nDims);
            
            % Initialize all dimensions as state dimensions
            for d = 1:numel(obj.dims)
                obj = obj.design(obj.dims(d), 'state');
            end
        end
    end
    
    % Object utilities
    methods
        [d, dims] = checkDimensions(obj, dims, allowMultiple);
        assertAddIndices(obj, indices, d, name);
        grid = gridfile(obj);
        checkGrid(obj, grid);
        obj = trim(obj);
        meta = dimMetadata(obj, grid, dim);
        obj = matchIndices(obj, meta, grid, dim);
        addIndex = addIndices(obj, d);
        subMembers = removeOverlap(obj, subMembers, dims);
    end
    
    % Interface methods
    methods
        obj = design(obj, dims, type, indices);
        obj = sequence(obj, dims, indices, metadata);
        
        obj = mean(obj, dims, indices, omitnan);
        obj = weightedMean(obj, dims, weights);
        obj = resetMeans(obj, dims);
        
        obj = specifyMetadata(obj, dim, metadata);
        obj = convertMetadata(obj, dim, convertFunction, functionArgs);
        obj = resetMetadata(obj, dims);
        
        dims = dimensions(obj, type);
        [varInfo, dimInfo] = info(obj);
        obj = rename(obj, newName);
        
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!! delete
        X = buildEnsemble(obj, subMembers, dims, grid, sources, ens, svRows, showprogress);
    end
    
    % New methods for rebuild
    methods
        obj = finalizeMean(obj);
        [Xm, sources] = loadMember(obj, subMember, s, grid, sources);
        [settings] = loadSettings(obj, subDims);
    end

end
        