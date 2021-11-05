classdef gridfileSources
    %% Manages additional data source details for gridfiles
    
    properties
        
        % Data source fields
        source = strings(0,1);      % The file path or opendap url to each data source
        relativePath = true(0,1);  % Whether to store source names as paths relative to the .grid file
        var = strings(0,1);         % Variable names for HDF sources
        importOptions = cell(0,1);  % Import options for delimited text sources
        importOptionSource = [];    % The index of the source corresponding to each import option
        
        % Gridfile dimensions
        dims = strings(0,1);        % The data dimensions in each source
        size = strings(0,1);        % The size of each dimension
        mergedDims = strings(0,1);  % The data dimensions after merging
        mergedSize = strings(0,1);  % The size of each merged dimension
        
        % Data transformations
        fill = NaN(0,1);                % Fill value
        range = NaN(0,2);               % Valid range
        transform = strings(0,1);       % Transformation type
        transform_params = NaN(0,2);    % Transformation parameters
    end
    
    methods
        obj = add(obj, grid, dataSource, dims, size, mergedDims, mergedSize);
        obj = remove(obj, s);
        s = indices(obj, sources, gridFile, header);
        paths = absolutePaths(obj, gridFile);
    end
end