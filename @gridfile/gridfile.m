classdef gridfile < handle
    
    properties (SetAccess = private)
        
        % Overall gridfile
        file = strings(0,1);            % The absolute path to the .grid file
        dims = strings(1,0);            % The gridfile dimensions
        size = NaN(1,0);                % The size of each gridfile dimension
        meta;                           % Dimensional metadata and attributes
        
        % Default transformations 
        fill = NaN;                     % Default fill value
        range = [-Inf, Inf];            % Default valid range
        transform_ = "none";            % Default data transformation
        transform_params = [NaN, NaN];  % Data transformation parameters
        
        % Data sources
        nSource = 0;                    % The number of data sources in the gridfile
        dimLimit = NaN(0,2,0);          % The limits of each data source in the gridfile dimensions
        relativePath = true;            % Whether to save data source file paths relative to the gridfile
        sources = dash.gridfileSources; % The collection of data sources
    end
    
    methods
        
        % File interactions
        update(obj);
        save(obj);
        
        % Metadata
        meta = metadata(obj);
        edit(obj, dim, value);
        addAttributes(obj, varargin);
        removeAttributes(obj, varargin);
        expand(obj, dim, value);
        
        % Data sources
        add(obj, type, source, varargin);
        remove(obj, sources);
        absolutePath(obj, useAbsolute, sources);
        
        % Data transformations
        fillValue(obj, fill, sources);
        validRange(obj, range, sources);
        transform(obj, type, params, sources);
        
        % Load
        dataSources = review(obj);
        load;
        repeatedLoad;
        
        % Arithmetic
        arithmetic(obj, operation, grid2, filename, overwrite, attributes, type);
        plus(obj, grid2, filename, varargin);
        minus(obj, grid2, filename, varargin);
        times(obj, grid2, filename, varargin);
        divide(obj, grid2, filename, varargin);
        
        % Summary information
        name = name(obj);
        disp(obj);
        dispSources(obj);
        info;
        
    end
    
    methods (Static)        
        obj = new(file, meta, overwrite);
    end
    
    % Constructor
    methods
        function[obj] = gridfile(filename)
        %% gridfile.gridfile  Create a gridfile object for a .grid file
        % ----------
        %   obj = gridfile(file)
        %   Returns a gridfile object for the indicated file.
        % ----------
        %   Inputs:
        %       filename (string scalar): The name of a .grid file.
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

        % Get the absolute file path
        file = dash.assert.strflag(filename, 'filename', header);
        file = dash.assert.fileExists(file, '.grid', header);
        obj.file = dash.file.urlSeparators(file);

        % Fill the object fields with values from the file
        obj.update;

        end
    end
end 