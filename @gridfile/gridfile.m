classdef gridfile < handle
    % A class that creates and edits .grid files. Each .grid file organizes
    % organizes a collection of gridded data. The .grid file stores
    % instructions on how to read data from different sources (such as
    % NetCDF and .mat files), and organizes metadata for the values in each
    % data source.
    %
    % To create a new gridfile object, use:
    %   obj = gridfile(filename)
    %
    % gridFile Methods:
    %   defineMetadata - Defines metadata for a .grid file or data source
    %   new - Initializes a new .grid file.
    %   gridfile - Creates a new gridfile object.
    %   add - Adds a data source to a .grid file.
    %   metadata - Returns the metadata for a .grid file.
    %   load - Loads values from the data sources organized by the .grid file
    % 
    % *** Advanced ***
    % gridFile Methods:
    %   info - Returns a summary of a .grid file's contents.
    %   rewriteMetadata - Rewrites metadata for a dimension in a .grid file
    %   renameSources - Changes the file name associated with a data source.
    %   expand - Increases the size of a dimension in a .grid file
    %   remove - Removes a data source from a .grid file.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    % Properties for the grid file object
    properties (SetAccess = private)
        file; % full name of the .grid file
        dims; % The dimensions recorded in the .grid file.
        size; % The size of the gridded dataset organized by the .grid file.
        isdefined; % Whether each dimension has defined metadata.
        meta; % The metadata along each dimension and data attributes
        source;  % Information for each data source
        fieldLength; % The length of primitive arrays for the source fields
        maxLength; % The length of the padded primitive arrays in the .grid file
        dimLimit; % The index limits of each data source in each dimension (nDim x 2 x nSource)
        absolutePath; % Whether to store a data source file name exclusively as an absolute path
    end
    
    % Global configuration.
    properties (Constant, Hidden)
        attributesName = 'attributes';
    end
    
    % Static utilities
    methods (Static)
        meta = checkMetadataField( meta, dim );
        meta = checkMetadataStructure( meta, dims, errorString );
        tf = hasDuplicateRows(meta);
        
        source = convertSourceToPrimitives(source);
        dims = commaDelimitedDims(dims);
        X = padPrimitives(X, maxCol);        
    end
    
    % Object utilities
    methods        
        varargout = collectPrimitives(obj, fields, sources);
        paths = collectFullPaths(obj, s);
        path = sourceFilepath(obj, path, relative);
        checkAllowedDims(obj, dims, requireDefined);
        
        update(obj);
        save(obj);
        updateMetadataField(obj, dim, meta);

        match = findFileSources(obj, file);
        sources = buildSources(obj, s);
        sources = buildSourcesForFiles(obj, s, filenames);
        checkSourcesMatchGrid(obj, sources, index);

        sources = review(obj);
        [X, meta, sources] = repeatedLoad(obj, inputOrder, inputIndices, sources);
    end
    
    % Static user methods
    methods (Static)
        meta = defineMetadata( varargin );
        grid = new(filename, meta, attributes, overwrite);
    end
    
    % User methods
    methods
        add(obj, type, file, var, dims, meta, varargin);
        remove( obj, file, var );
        renameSources(obj, name, newname, relativePath);

        rewriteMetadata( obj, dim, meta );
        expand(obj, dim, meta);
        [gridInfo, sourceInfo] = info(obj, sources);

        meta = metadata(obj, includeUndefined);
        [X, meta] = load(obj, start, count, stride);
    end
    
    % Constructor
    methods
        function[obj] = gridfile( file )
        % Creates a gridfile object for a saved .grid file.
        %
        % obj = gridfile( filename )
        % Finds a .grid file with the specified name on the active path
        % and returns an associated gridfile object.
        %
        % obj = gridfile( fullname )
        % Returns a gridfile object for a .grid file with the specified
        % full file name (including path).
        %
        % ----- Inputs -----
        %
        % filename: A file name. A string.
        %
        % fullname: A full file name (including path). A string.
        %
        % ----- Outputs -----
        %
        % obj: A gridfile object for the specified .grid file.
            
            % Check the input is a file name
            file = dash.assertStrFlag(file, "file");
            obj.file = dash.checkFileExists(file);
            
            % Fill the fields
            obj.update;
        end
    end
    
end