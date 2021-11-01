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
        
        %% Non-dimensional metadata attributes
        % This should always be the last listed property.
        attributes = struct();
    end

    methods       
        
        % Properties / dimensions
        function[obj] = gridMetadata(varargin)
        %% gridMetadata.gridMetadata  Creates a new gridMetadata object
        % ----------
        %   obj = gridMetadata(dim1, meta1, dim2, meta2, ..., dimN, metaN)
        %   Creates a metadata object for a gridded dataset.
        %
        %   obj = gridMetadata(..., 'attributes', attributes)
        %   Include non-dimensional metadata attributes in the metadata object
        % ----------
        %   Inputs:
        %       dimN (string scalar): The name of a dimension of a gridded dataset.
        %           Must be a recognized grid dimension. 
        %           (See gridMetadata.dimensions for a list of available dimensions)
        %       metaN (matrix, numeric | logical | char | string | cellstring | datetime): 
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

        % Header for error IDs
        header = "DASH:metadata:define";
        
        % Get the set of recognized dimensions and attributes. Track user
        % input dimensions
        [dims, atts] = gridMetadata.dimensions;
        names = [dims;atts];
        nNames = numel(names);
        isSet = false(nNames,1);
        
        % Require an even number of inputs
        if mod(nargin, 2)~=0        
            id = sprintf('%s:oddNumberOfInputs', header);
            error(id, 'There must be an even number of inputs. (Inputs should be Name, Value pair arguments)');
        end
        
        % Check that the first argument in each pair is a valid dimension name
        for v = 1:2:nargin-1
            inputName = sprintf('Input %.f', v);
            dim = dash.assert.strflag(varargin{v}, inputName, header);
            n = dash.assert.strsInList(dim, names, inputName, 'recognized dimension name', header);
            
            % Prevent duplicates
            if isSet(n)
                id = sprintf('%s:repeatedDimension', header);
                error(id, 'Dimension name "%s" is listed multiple times', dim); 
            end
            isSet(n) = true;
            
            % Error check and update metadata
            obj = obj.edit(dim, varargin{v+1});
        end
        
        end
        obj = edit(obj, name, value);
        dims = defined(obj);
        
        % Console display
        disp(obj);
        dispAttributes(obj);
        
    end
    
    methods (Static)
        
        % Dimension names (configuration)
        [dims, atts] = dimensions;
        
        % Input error checking
        meta = assertField(meta, dim, idHeader);
        tf = hasDuplicateRows(meta);
    end
    
end