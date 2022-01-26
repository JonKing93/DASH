classdef gridMetadata
%% gridMetadata  Organize metadata for gridded datasets
% ----------
%   gridMetadata objects help define the metadata for an N-dimensional
%   gridded dataset. Each object supports metadata for the following
%   dimensions:
%
%   1. lon: longitude / x-coordinate
%   2. lat: latitude / y-coordinate
%   3. lev: level / height / z-coordinate
%   4. site: non-cartesian spatial coordinate
%   5. time: time
%   6. run: run / ensemble member
%   7. var: climate variable
%
%   although datasets are not required to implement all 7 dimensions. The
%   class can also be customized to include additional dimensions or
%   to rename the default dimensions.
%
%   gridMetadata objects also include support for non-dimensional
%   metadata via an "attributes" field, which can include data of any
%   type.
% ----------
% gridMetadata Methods:
%
% **KEY METHODS**
% The following are the most essential methods for users.
%
%   gridMetadata     - Create a new gridMetdata object
%   edit             - Edit the metadata for a gridded dataset
%   index            - Return metadata at indexed rows
%
%   
% *ALL USER METHODS*
% The complete list of gridMetadata methods for users.
%
% Create / Edit:
%   gridMetadata     - Create a new gridMetdata object
%   edit             - Edit the metadata for a gridded dataset
%   index            - Return metadata at specified indices
%   setOrder         - Specify a dimension order for a gridded dataset
%
% Attribute Manipulation:
%   addAttributes    - Add non-dimensional attributes to the metadata for a gridded dataset
%   removeAttributes - Remove attributes from the metadata of a gridded dataset
%   editAttributes   - Replace non-dimensional attributes with new values
%
% List Dimensions:
%   dimensions       - Return the list of supported gridMetadata dimensions
%   defined          - Return a list of dimensions with defined metadata
%
%
% ==UTILITIES==
% Under the hood methods that help the class run. These are not intended
% for most users.
%
% Console Display:
%   disp             - Display gridMetadata object in console
%   dispAttributes   - Display metadata attributes in the console
%
% Assertions:
%   assertField      - Throw error if input is not a valid metadata field
%   assertUnique     - Throw error if metadata rows are not unique
%
% Unit Tests:
%   tests            - Implement unit tests for the gridMetadata class
%
% <a href="matlab:dash.doc('gridMetadata')">Documentation Page</a>
    
    properties (SetAccess = private)
    
        %% Built-in dimensions
        % These dimensions are hard-coded into various functions in DASH.
        % You CAN rename these dimensions, but DO NOT delete them
        % and DO NOT change their order.
        
        lon;    % Longitude / X-Axis
        lat;    % Latitude / Y-Axis
        lev;    % Level / Height / Z-Axis
        site;   % For proxy sites / tripolar grids / spatial data not on Cartesian Axes
        time;   % Time
        run;    % Run / Ensemble member
        var;    % Climate variable
        
        %% ----- Insert new dimensions after this line -----
        % If you would like to add new dimensions to DASH, add them between
        % the two indicated lines
        
        
        
        %  ----- Stop adding dimensions after this line -----
        
        %% Non-dimensional properties
        
        attributes = struct();  % Non-dimensional metadata attributes
        order = strings(1,0);   % The order of dimensions in a gridded array
    end

    methods       
        
        % Properties / dimensions
        obj = edit(obj, dimensions, metadata, varargin);
        obj = setOrder(obj, varargin);
        obj = index(obj, dimensions, indices, varargin);
        [dims, size] = defined(obj);
        
        % Console display
        disp(obj);
        dispAttributes(obj);
        
        % Attribute manipulation
        obj = addAttributes(obj, fields, values, varargin);
        obj = removeAttributes(obj, varargin);
        obj = editAttributes(obj, fields, values, varargin);
        
        % Assertions
        assertUnique(obj, dimensions, header);        
    end
    
    methods (Static)        
        
        % Configuration
        [dims, atts] = dimensions;
        meta = assertField(meta, dim, idHeader);
        
        % Unit tests
        tests;
    end
    
    % Constructor
    methods
        function[obj] = gridMetadata(varargin)
        %% gridMetadata.gridMetadata  Creates a new gridMetadata object
        % ----------
        %   obj = gridMetadata(dimension1, metadata1, dimension2, metadata2, .., dimensionN, metadataN)
        %   Creates a metadata object for a gridded dataset.
        %
        %   obj = gridMetadata(..., 'attributes', attributes)
        %   Include non-dimensional metadata attributes in the metadata object
        %
        %   obj = gridMetadata(dimensions, metadata)
        %   Uses an alternate syntax to create a metadata object. In this
        %   syntax, collect all dimension names into a string vector, and
        %   corresponding metadata/attributes in a cell vector.
        %
        %   obj = gridMetadata(s)
        %   Creates a metadata object from a struct template. Fields of the
        %   struct that match dimension names or 'attributes' are copied as
        %   metadata.
        % ----------
        %   Inputs:
        %       dimensionN (string scalar): The name of a dimension of a gridded dataset.
        %           Must be a recognized grid dimension. 
        %           (See gridMetadata.dimensions for a list of available dimensions)
        %       metadataN (matrix, numeric | logical | char | string | cellstring | datetime): 
        %           The metadata for the dimension. Cannot have NaN or NaT elements.
        %       attributes (scalar struct): Non-dimensional metadata attributes for
        %           a gridded dataset. May contain any fields or contents useful
        %           for the user.
        %       dimensions (string vector [nDimensions]): The list of all
        %           dimensions to create in the metadata object. May also
        %           include the string "attributes" in order to create
        %           non-dimensional attributes.
        %       metadata (cell vector [nDimensions] {metadata matrix | scalar struct}):
        %           The metadata for each dimension listed in the "dimensions" input.
        %           Each metadata value should follow the format described for the
        %           "metadataN" input above. Metadata for  non-dimensional attributes
        %           should be a scalar struct, which may contain any fields or values.
        %       s (scalar struct): A template for a gridMetadata object.
        %           May contain any fields, but fields that match dimension
        %           names or 'attributes' are copied as metadata for the
        %           new gridMetadata object.
        %
        %   Outputs:
        %       obj (gridMetadata object): The metadata object for a gridded
        %           dataset. The properties/fields of the object are the dimensions
        %           with metadata (dimN). Each field holds the associated metadata
        %           matrix (metaN). Cellstring metadata are converted to string.
        %
        % <a href="matlab:dash.doc('gridMetadata.gridMetadata')">Documentation Page</a>
        
        % Parse struct fields
        if numel(varargin)==1 && isscalar(varargin{1}) && isstruct(varargin{1})
            s = varargin{1};
            fields = string(fieldnames(s))';
            
            % Get fields to copy
            [dims, atts] = obj.dimensions;
            copyable = [dims;atts];
            copy = ismember(fields, copyable);
            fields = fields(copy);
            nFields = numel(fields);
            
            % Get the values to copy
            metadata = cell(1, nFields);
            for f = 1:nFields
                metadata{f} = s.(fields(f));
            end
            varargin = [cellstr(fields); metadata];
        end 
        
        % Build the metadata
        obj = obj.edit(varargin{:});
        
        end
    end
end