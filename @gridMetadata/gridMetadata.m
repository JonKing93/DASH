classdef gridMetadata
    %% gridMetadata  Implements metadata for gridded datasets
    %
    
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
        order = strings(1,0);                  % The order of dimensions in a gridded array
    end

    methods       
        
        % Properties / dimensions
        obj = edit(obj, varargin);
        dims = defined(obj);
        obj = setOrder(obj, varargin);
        
        % Console display
        disp(obj);
        dispAttributes(obj);
        
        % Attribute manipulation
        obj = addAttributes(obj, varargin);
        obj = removeAttributes(obj, varargin);
        obj = editAttributes(obj, varargin);
        
        % Test metadata uniqueness
        assertUnique(obj, header);
        
        % Constructor
        function[obj] = gridMetadata(varargin)
        %% gridMetadata.gridMetadata  Creates a new gridMetadata object
        % ----------
        %   obj = gridMetadata(dimension1, metadata1, dimension2, metadata2, .., dimensionN, metadataN)
        %   Creates a metadata object for a gridded dataset.
        %
        %   obj = gridMetadata(..., 'attributes', attributes)
        %   Include non-dimensional metadata attributes in the metadata object
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
        obj = obj.edit(varargin{:});
        end
    end
    
    % Configuration - Dimension names and valid metadata fields
    methods (Static)        
        [dims, atts] = dimensions;
        meta = assertField(meta, dim, idHeader);
    end
    
end