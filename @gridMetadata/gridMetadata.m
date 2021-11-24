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
%   index            - Return metadata at specified indices
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
%   assertScalar     - Throw error if gridMetadata object is not scalar
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
        obj = edit(obj, varargin);
        dims = defined(obj);
        obj = setOrder(obj, varargin);
        obj = index(obj, dimensions, indices, varargin);
        
        % Console display
        disp(obj);
        dispAttributes(obj);
        
        % Attribute manipulation
        obj = addAttributes(obj, varargin);
        obj = removeAttributes(obj, varargin);
        obj = editAttributes(obj, varargin);
        
        % Assertions
        assertUnique(obj, header);        
        assertScalar(obj, header);
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
        %           All rows must be unique.
        %       attributes (scalar struct): Non-dimensional metadata attributes for
        %           a gridded dataset. May contain any fields or contents useful
        %           for the user.
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
        %   Throws:
        %       DASH:gridMetadata:oddNumberOfInputs  if an odd number of inputs
        %           are passed to the function
        %       DASH:gridMetadata:repeatedDimension  if a dimension name
        %           repeated in the inputs
        %       DASH:gridMetadata:invalidDimensionName  if a dimension name is
        %           not a valid MATLAB variable name
        %       (Warning) DASH:metadata:define:metadataFieldIsRow  if a metadata
        %           field is a row vector%
        %
        % <a href="matlab:dash.doc('gridMetadata.gridMetadata')">Documentation Page</a>
        
        % Build from struct
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