classdef gridfileSources
    %% dash.gridfileSources  Implement a gridfile's catalogue of data sources
    % ----------
    % dash.gridfileSources methods:
    %
    % Catalogue Management:
    %   add           - Add a new data source to the catalogue
    %   remove        - Remove data sources from the catalogue
    %   indices       - Parse the indices of data sources in the catalogue
    %   unpack        - Convert catalogued values to their original data types
    %   info          - Return information about data sources in the catalogue
    %
    % dataSource Objects:
    %   build         - Build the dataSource object for a data source in the catalogue
    %   ismatch       - Test if a dataSource object matches an entry in the catalogue
    %
    % File Paths:
    %   absolutePaths - Return the absolute paths to data sources in the catalogue
    %   savePath      - Record the path to a data source in the catalogue
    %
    % Unit tests:
    %   tests         - Unit tests for the dash.gridfileSources class
    %
    % <a href="matlab:dash.doc('dash.gridfileSources')">Documentation Page</a>
    
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
        s = indices(obj, sources, header);
        [dims, size, mergedDims, mergedSize, mergeMap] = unpack(obj, s);
        info = info(obj, s)
        
        % Data source objects
        dataSource = build(obj, s, filepath);
        [tf, property, sourceValue, gridValue] = ismatch(obj, dataSource, s);
        
        % File paths
        paths = absolutePaths(obj, gridFile);
        obj = savePath(obj, dataSource, tryRelative, s)
    end
    
    % Unit tests
    methods (Static)
        tests;
    end
end