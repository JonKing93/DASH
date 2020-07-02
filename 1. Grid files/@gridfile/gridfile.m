classdef gridfile < handle
    % A class that creates and edits .grid files. Each .grid file organizes
    % organizes a collection of gridded data. The .grid file stores
    % instructions on how to read data from different sources (such as
    % NetCDF and .mat files), and organizes metadata for the values in each
    % data source.
    %
    % *** Essential ***
    % gridFile Methods:
    %   defineMetadata - Defines metadata for a .grid file or data source
    %   new - Initializes a new .grid file.
    %   add - Adds a data source to a .grid file.
    %   metadata - Returns the metadata for a .grid file.
    % 
    % *** Advanced ***
    % gridFile Methods:
    %   expand - Increases the size of a dimension in a .grid file
    %   rewriteMetadata - Rewrites metadata for a dimension in a .grid file
    %   info - Returns a summary of a .grid file.
    %   read - Reads out data from a .grid file
    %   remove - Removes a data source from a .grid file.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    % Properties for the grid file object
    properties
        file; % full name of the .grid file
        dims; % The dimensions recorded in the .grid file.
        size; % The size of the gridded dataset organized by the .grid file.
        isdefined; % Whether each dimension has defined metadata.
        meta; % The metadata along each dimension and data attributes
        source;  % Information for each data source
        fieldLength; % The length of primitive arrays for the source fields
        maxLength; % The length of the padded primitive arrays in the .grid file
        dimLimit; % The index limits of each data source in each dimension (nDim x 2 x nSource)
    end
    
    % Global configuration.
    properties (Constant, Hidden)
        attributesName = 'attributes';
    end
    
    % Static utilities
    methods (Static)
        checkMetadataField( meta, dim );
        checkMetadataStructure( meta );
        tf = hasDuplicateRows(meta);
        source = convertSourceToPrimitives(source);
        dims = commaDelimitedDims(dims);
        X = padPrimitives(X, maxCol);
    end
    
    % Object utilities
    methods
        update(obj);
        save(obj);
        varargout = collectPrimitives(obj, fields);
        match = findFileSources(obj, file);
    end
    
    % Static user methods
    methods (Static)
        meta = defineMetadata( varargin );
        meta = metadata(file, includeUndefined);
        grid = new(filename, meta, attributes, overwrite);
    end
    
    % User methods
    methods
        add(obj, type, file, var, dims, meta);
        expand(obj, dim, meta);
        rewriteMetadata( obj, dim, meta );
        remove( obj, file, var );
    end
    
    % Constructor
    methods
        function[obj] = gridfile( file )
        warning('This constructor is only for testing!!!');
        obj.file = string(which(file));
        m = matfile(obj.file);
        obj.dims = m.dims;
        obj.size = m.gridSize;
        obj.isdefined = m.isdefined;
        obj.meta = m.metadata;
        obj.source = m.source;
        obj.fieldLength = m.fieldLength;
        obj.maxLength = m.maxLength;
        obj.dimLimit = m.dimLimit;
        end
    end
            
    
end