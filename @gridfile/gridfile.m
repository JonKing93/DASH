classdef gridfile < handle
    %% gridfile  Catalogue and load gridded data sets
    % ----------
    %   The gridfile class creates and manages gridfile objects. These
    %   objects catalogue metadata and source files for a gridded dataset.
    %   The catalogue is stored in a file with a ".grid" extension.
    %
    %   A key function of gridfile is to provide an interface for loading
    %   data from the source files. This interface allows the user to
    %   efficiently:
    %
    %       1. Load subsets of the catalogued data
    %       2. Order the dimensions of loaded data
    %       3. Apply linear or log transforms to loaded data, and
    %       4. Perform simple arithmetic on large gridded datasets
    %
    %   Another function of gridfile is to associate all gridded data
    %   with dimensional metadata. This allows data to be accessed using
    %   human-readable metadata, rather than array indices.
    % ----------
    % gridfile methods:
    %
    % **KEY METHODS**
    % The following methods are the most essential methods for users.
    %
    %   new             - Create a new, empty .grid file
    %   gridfile        - Return a gridfile object for a .grid file.
    %   add             - Catalogue a data source in a .grid file
    %   metadata        - Return the metadata for a gridfile
    %   load            - Load data from the sources catalogued in a .grid file
    %
    %
    % *ALL USER METHODS*
    % The complete list of gridfile methods for users.
    %
    % Create:
    %   new              - Create a new, empty .grid file
    %   gridfile         - Return a gridfile object for a .grid file.
    %
    % Metadata:
    %   metadata         - Return the metadata for a gridfile
    %   edit             - Rewrite gridfile metadata
    %   expand           - Increase the length of a dimension in a .grid file
    %   addDimension     - Add a new dimension to a .grid file
    %
    % Metadata attributes:
    %   addAttributes    - Add attributes to gridfile metadata
    %   removeAttributes - Remove attributes from the metadata of a gridded dataset
    %   editAttributes   - Change existing metadata attributes
    %
    % Data sources:
    %   add              - Catalogue a data source in a .grid file
    %   remove           - Remove data sources from a .grid file's catalogue
    %   rename           - Update paths to data sources catalogued in a gridfile
    %   absolutePaths    - Save data source file names as absolute or relative paths
    %
    % Data adjustments:
    %   fillValue        - Specify a fill value for data catalogued in a .grid file
    %   validRange       - Specify a valid range for data catalogued in a .grid file
    %   transform        - Transform data loaded from a .grid file
    %
    % Load:
    %   load             - Load data from the sources catalogued in a gridfile
    %
    % Arithmetic:
    %   plus             - Sum the data in two gridfiles
    %   minus            - Subtract the data in a gridfile from the current gridfile
    %   times            - Multiply the data in two gridfiles
    %   divide           - Divide the data in the current gridfile by a second gridfile
    %
    % Summary Information:
    %   sources          - Return the ordered list of data sources in a gridfile
    %   dimensions       - Return the dimensions in a gridfile and their sizes
    %   info             - Return information about a gridfile object
    %   name             - Return the name of the .grid file, excluding path
    %
    %
    % ==UTILITY METHODS==
    % Under-the-hood methods that help the class run. These are not intended
    % for users.
    %
    % File interactions:
    %   update           - Update a gridfile object to match the contents of its .grid file
    %   save             - Save a gridfile object to a .grid file
    %
    % Console Display:
    %   disp             - Display gridfile object in console
    %   dispSources      - List gridfile data sources in the console
    %   dispAdjustments  - Print fill value, valid range, and data transformation to console
    %
    % Load:
    %   getLoadIndices   - Organize the dimension indices required to implement a load operation
    %   sourcesForLoad   - Return the indices of data sources needed to load requested data
    %   buildSources     - Build dataSources for a gridfile load
    %   loadInternal     - Load requested data from pre-built dataSource objects
    %
    % Arithmetic:
    %   arithmetic       - Arithmetic operations across two gridfiles
    %
    % Unit tests:
    %   tests            - Unit tests for the gridfile class
    %
    % <a href="matlab:dash.doc('gridfile')">Documentation Page</a>
    
    properties (SetAccess = private)
        
        %% General gridfile
        % (Used to define the N-dimensional grid and its location)
        
        file = strings(0,1);            % The absolute path to the .grid file
        dims = strings(1,0);            % The gridfile dimensions
        size = NaN(1,0);                % The size of each gridfile dimension
        meta;                           % Dimensional metadata and attributes
        
        %% Default data adjustments 
        
        fill = NaN;                     % Default fill value
        range = [-Inf, Inf];            % Default valid range
        transform_ = "none";            % Default data transformation
        transform_params = [NaN, NaN];  % Default data transformation parameters
        
        %% Data sources
        
        nSource = 0;                     % The number of data sources in the gridfile
        dimLimit = NaN(0,2,0);           % The limits of each data source in the gridfile dimensions
        relativePath = true;             % Whether to save data source file paths relative to the gridfile
        sources_ = dash.gridfileSources; % The collection of data sources
    end
    
    methods
        
        % File interactions
        update(obj);
        save(obj);
        
        % Metadata
        meta = metadata(obj, sources);
        edit(obj, dim, value);
        expand(obj, dim, value);
        addDimension(obj, dim, value);
        
        % Metadata attributes
        addAttributes(obj, varargin);
        removeAttributes(obj, varargin);        
        editAttributes(obj, varargin)
        
        % Data sources
        add(obj, type, source, varargin);
        remove(obj, sources);
        rename(obj, sources, newNames);
        absolutePaths(obj, useAbsolute, sources);
        
        % Data adjustments
        varargout = fillValue(obj, fill, sources);
        range = validRange(obj, range, sources);
        [transform, parameters] = transform(obj, type, params, sources);
        
        % Load
        loadIndices = getLoadIndices(obj, userDims, userIndices);
        s = sourcesForLoad(obj, loadIndices);
        [dataSources, failed, causes] = buildSources(obj, s, fatal, filepaths);
        [X, meta] = loadInternal(obj, userDimOrder, loadIndices, s, dataSources, precision);      
        [X, meta] = load(obj, dimensions, indices, precision)
        
        % Arithmetic
        arithmetic(obj, operation, grid2, filename, overwrite, attributes, type, precision);
        plus(obj, grid2, filename, varargin);
        minus(obj, grid2, filename, varargin);
        times(obj, grid2, filename, varargin);
        divide(obj, grid2, filename, varargin);
        
        % Summary information
        name = name(obj);
        sources = sources(obj, s);
        [dimensions, sizes] = dimensions(obj);
        info = info(obj, s)
        disp(obj);
        dispSources(obj);
    end
    
    methods (Static)
        dispAdjustments(fill, range, transformType, transformParams);
        obj = new(file, meta, overwrite);
        tests;
    end
    
    % Constructor
    methods
        function[obj] = gridfile(filename)
        %% gridfile.gridfile  Return a gridfile object for a .grid file
        % ----------
        %   obj = gridfile(filename)
        %   Builds a gridfile object for the specified file.
        %
        %   obj = gridfile(filenames)
        %   Builds an array of gridfiles for the specified files. The
        %   output array will have the same size as the "filenames" input,
        %   and each element will be the gridfile object for the
        %   corresponding file.
        % ----------
        %   Inputs:
        %       filenames (string array | cellstring array | character row vector): 
        %           The name of the .grid files for which to build gridfile
        %           objects. The output gridfile array will have the same
        %           size as this input.
        %  
        %   Outputs:
        %       obj (gridfile object): A gridfile object for the file.
        %
        % <a href="matlab:dash.doc('gridfile.gridfile')">Documentation Page</a>
        
        %% Hidden documentation
        % ----------
        %   obj = gridfile
        %   Initializes an empty gridfile. The returned gridfile will not
        %   have an associated file. It will not
        %   be valid for user methods, so this syntax is hidden. It should
        %   not appear in function help text or documentation pages. 
        %
        %   This functionality is used by the "gridfile.new" command when
        %   initializing an empty .grid file, and this syntax can ONLY be
        %   called from that command.
        % ----------
        %   Outputs:
        %       obj (gridfile object): An empty gridfile object. The "file"
        %           property is empty, so the object is not valid for
        %           gridfile commands.
        
        %% Empty syntax (hidden)
        % Return an empty object. Only allow this syntax from gridfile.new.
        if ~exist('filename','var')    
            stack = dbstack('-completenames');
            if numel(stack)>1
                currentPath = fileparts(stack(1).file);
                [previousPath, previousFile] = fileparts(stack(2).file);
                if isequal(currentPath, previousPath) && strcmp(previousFile, 'new')
                    return;
                end
            end
        end
            
        %% Regular syntax
        
        % Header for error IDs
        header = "DASH:gridfile";
        
        % Require strings array with at least one element
        if ~dash.is.string(filename)
            id = sprintf('%s:invalidType', header);
            error(id, 'filenames must be either a string array, cellstring array, or character row vector');
        end
        filename = string(filename);
        if isempty(filename)
            id = sprintf('%s:emptyFilenames', header);
            error(id, 'filenames cannot be empty');
        end

        % If scalar, build the gridfile
        if isscalar(filename)
            file = dash.assert.strflag(filename, 'filename', header);
            file = dash.assert.fileExists(file, '.grid', header);
            obj.file = dash.file.urlSeparators(file);
        
            % Fill the object fields with values from the file
            obj.update;
        
        % If not scalar, preallocate gridfile array
        else
            nFiles = numel(filename);
            obj = cell(nFiles, 1);
        
            % Get object for each file
            try
                for k = 1:nFiles
                    obj{k} = gridfile(filename(k));
                end

            % If failed, note which file caused the error
            catch cause
                id = sprintf('%s:couldNotBuildGridfile', header);
                ME = MException(id, 'Could not build the gridfile object for filename %.f (%s).', k, filename(k));
                ME = addCause(ME, cause);
                throw(ME);
            end
        
            % Convert cell array to gridfile array
            obj = [obj{:}];
            obj = reshape(obj, size(filename));
        end

        end
    end
end 