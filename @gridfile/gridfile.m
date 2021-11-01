classdef gridfile < handle
    
    properties
        
        % Overall gridfile
        file;
        dims;
        size;
        metadata;
        
        % Default transformations
        fill;
        range;
        transform;
        transform_type;
        transform_params;
        
        % Data sources
        source;
        relativePath;
        dimLimit;
        
        % Data source transformations
        source_fill;
        source_range;
        source_transform;
        source_transform_type;
        source_transform_params;
    end
    
    methods
        
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

        % Header for error IDs
        header = "DASH:gridfile";

        % Get the absolute file path
        file = dash.assert.strflag(filename, 'filename', header);
        obj.file = dash.assert.fileExists(file, '.grid', header);

        % Fill the object fields
        obj.update;

        end
    end
end 