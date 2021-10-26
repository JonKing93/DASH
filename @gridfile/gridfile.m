classdef gridfile < handle
    % gridfile  Catalogue and load gridded data sets
    % ----------
    %   The gridfile class creates and manages gridfile objects. These
    %   objects catalogue 1. metadata, and 2. data source files for a
    %   gridded dataset. The catalogue is stored in a file with a ".grid"
    %   extension.
    %
    %   A key function of gridfile is to provide an interface for loading
    %   data from the source files. This interface allows the user to
    %   efficiently:
    %       1. Load subsets of the catalogued data
    %       2. Order the dimensions of loaded data
    %       3. Apply linear or log transforms to loaded data, and
    %       4. Perform simple arithmetic on large gridded datasets
    %
    %   The other key function of gridfile is to associate all gridded data
    %   with dimensional metadata. This allows data to be accessed using
    %   human-readable metadata, rather than array indices.
    % ----------
    % gridfile methods:
    %
    % KEY METHODS
    % The following methods are the most commonly used methods by users.
    %
    % Essential:  Core functionality
    %   gridfile        - Build the gridfile object for a .grid file
    %   metadata        - Return the metadata for a gridfile object
    %   new             - Create a new (empty) .grid file
    %   add             - Catalogue a data source file in a .grid file
    %   defineMetadata  - Organize dimensional metadata for a .grid file or data source file.
    %   load            - Load data from source files.
    %
    %
    % ALL USER METHODS:
    % The complete list of gridfile methods for users.
    %
    % Arithmetic:
    %   plus - 
    %   minus - 
    %   times - 
    %   divide -
    %
    % Create gridfile:
    %   gridfile - 
    %   new - 
    %
    % Data transformations:
    %   fillValue - 
    %   validRange - 
    %   transform - 
    %
    % Data sources:
    %   add - 
    %   remove - 
    %   renameSources - 
    %
    % Load data:
    %   load - 
    %
    % Metadata:
    %   defineMetadata - 
    %   editMetadata -
    %   metadata - 
    %   expand -
    %
    % Summary:
    %   info - 

    % UTILITY METHODS:
    % "Under-the-hood" methods used internally to run the gridfile objects.
    % These methods may be useful to developers, but are not intended for
    % users.
    %
    % Data sources:
    %   findFileSources -
    %   buildSources - 
    %   buildSourcesForFiles - 
    %   checkSourcesMatchGrid -
    %   sourceFilepath - 
    %
    % Load:
    %   review - 
    %   repeatedLoad - 
    %
    % Misc:
    %   collectFullPaths - 
    %   checkAllowedDims - 
    %
    % Primitive Conversion:
    %   padPrimitives - 
    %   convertSourceToPrimitives -
    %   collectPrimitives - 
    %
    % Save and update:
    %   save - 
    %   update - 
    %   updateMetadataField -
    
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
        source = convertSourceToPrimitives(source);
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
            file = dash.assert.strflag(file, "file");
            obj.file = dash.assert.fileExists(file, '.grid');
            
            % Fill the fields
            obj.update;
        end
    end
    
end