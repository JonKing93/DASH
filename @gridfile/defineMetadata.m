function[meta] = defineMetadata( varargin )
% Creates a structure to define the metadata of a gridded dataset.
%
% meta = gridfile.defineMetadata( dim1, meta1, dim2, meta2, ..., dimN, metaN )
% Defines the metadata for specified data dimensions.
%
% ----- Inputs -----
%
% dimN: The name of the Nth dimension for which metadata is specified. A
%    string. Names cannot be specified more than once. See 
%    dash.dimensionNames for a list of recognized data dimension names.
%
% metaN: Metadata for the Nth specified dimension. A numeric, logical,
%    char, string, cellstring, or datetime matrix. Each row is treated
%    as the metadata for one dimension element. Each row must be unique
%    and cannot contain NaN or NaT elements. Cellstring metadata
%    will be converted into the "string" type.
%
% ----- Outputs -----
%
% meta: The metadata structure defined by the inputs.

% Check that the number of metadata elements is even
nDim = nargin /2;
if mod(nDim,1)~=0
    error('There must be an even number of inputs. One metadata matrix for each specified dimension name.');
end

% Get rcognized dimension names. Track user dimensions. Initialize output
userDims = strings(nDim,1);
meta = struct();

% Prevent duplicate dimension names
for v = 1:2:nargin-1
    dash.assertStrFlag( varargin{v}, sprintf("Input %.f",v) );
    if ismember( varargin{v}, userDims )
        error('Dimension name "%s" is specified multiple times.', varargin{v});
    end
    userDims((v+1)/2) = string(varargin{v});
end

% Error check the input metadata values
for v = 2:2:nargin
    dim = varargin{v-1};
    value = varargin{v};
    value = gridfile.checkMetadataField(value, dim);
    
    % Warn user if metadata is a row vector. (They probably want a column)
    if isrow(value) && ~isscalar(value)
        warning('The %s metadata is a row vector and will be used for a single %s element.', varargin{v-1}, varargin{v-1});
    end
    
    % Add to the output metadata structure
    meta.(varargin{v-1}) = value;
end

end