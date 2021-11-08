classdef gridfileSources
    %% Manages additional data source details for gridfiles
    
    properties
        
        % Parent gridfile information
        gridfile = "";                  % The name of the parent gridfile
        
        % General data source fields
        type = strings(0,1);            % mat, nc, or text
        source = strings(0,1);          % The file path or opendap url to each data source
        relativePath = true(0,1);       % Whether the file source is a relative or absolute path
        dataType = strings(0,1);        % The data type of the data stored in the source
        
        % Type-specific data source fields
        var = strings(0,1);             % Variable names for HDF sources
        importOptions = cell(0,1);      % Import options for delimited text sources
        importOptionSource = [];        % The index of the source corresponding to each import option
        
        % Gridfile dimensions
        dims = strings(0,1);            % The data dimensions in each source
        size = strings(0,1);            % The size of each dimension
        mergedDims = strings(0,1);      % The data dimensions after merging
        mergedSize = strings(0,1);      % The size of each merged dimension
        mergeMap = strings(0,1);        % The location of each original dimension after merging
        
        % Data transformations
        fill = NaN(0,1);                % Fill value
        range = NaN(0,2);               % Valid range
        transform = strings(0,1);       % Transformation type
        transform_params = NaN(0,2);    % Transformation parameters
    end
    
    methods
        
        % Array management
        obj = add(obj, grid, dataSource, dims, size, mergedDims, mergedSize, mergeMap);
        obj = remove(obj, s);
        s = indices(obj, sources, gridFile, header);
        
        % Data source objects
        dataSource = build(obj, s, filepath);
        [tf, property, sourceValue, gridValue] = ismatch(obj, dataSource, s);
        
        % File paths
        paths = absolutePaths(obj, gridFile);
        obj = savePath(obj, dataSource, tryRelative, s)
    end
end