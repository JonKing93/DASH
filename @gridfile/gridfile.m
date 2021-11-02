classdef gridfile < handle
    
    properties
        
        % Overall gridfile
        file = strings(0,1);
        dims = strings(1,0);
        sizes = NaN(1,0);
        meta;
        
        % Default transformations
        fill = NaN;
        range = [-Inf, Inf];
        transform = false;
        transform_type = "none";
        transform_params = [NaN, NaN];
        
        % Data sources
        source = strings(0,1);
        relativePath = false(0,1);
        dimLimit = NaN(0,2);
        
        % Data source transformations
        source_fill = NaN(0,1);
        source_range = NaN(0,2);
        source_transform = false(0,1);
        source_transform_type = strings(0,1);
        source_transform_params = NaN(0,2);
    end
    
    methods
        
        % File interactions
        update(obj);
        save(obj);
        
        % Metadata
        meta = metadata(obj);
        edit(obj, dim, value);
        expand(obj, dim, value);
        
        addAttributes;
        removeAttributes;
        attributes;
        
        
        
        
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
        obj.file = dash.assert.fileExists(file, '.grid', header);

        % Fill the object fields with values from the file
        obj.update;

        end
    end
end 