function[meta] = defineMetadata( varargin )
% Creates a structure to define the metadata of a gridded dataset.
%
% meta = gridFile.defineMetadata( dim1, meta1, dim2, meta2, ..., dimN, metaN )
% Sets the metadata for specified data dimensions.
%
% ----- Inputs -----
%
% dimN: The name of the Nth dimension for which metadata is specified. A
%       string. Names cannot be specified more than once. 
%       See dash.dimensionNames for a list of recognized data dimension names.
%
% metaN: Metadata for the Nth specified dimension. A numeric, logical,
%        char, string, cellstring, or datetime matrix. Each row is treated
%        as the metadata for one dimension element. Each row must be unique
%        and cannot contain NaN, Inf, or NaT elements. Cellstring metadata
%        will be converted into the "string" type.
%
% ----- Outputs -----
%
% meta: The metadata structure defined by the inputs.

% Check that the number of metadata elements is even
nDim = nargin /2;
if mod(nDim,1)~=0
    error('There must be an even number of inputs. One metadata matrix for each specified dimension name.');
end

% Get recognized dimension names. Track user dimensions. Initialize output
allDims = dash.dimensionNames;
usedDims = NaN(nDim, 1);
meta = struct();

% Error check the user dimension names. Prevent duplicates.
for v = 1:2:nargin-1
    if ~dash.isstrflag( varargin{v} )
        error('Input %0.f must be a string scalar or character row vector.', v);
    end
    
    [recognized, d] = ismember( varargin{v}, allDims );
    if ~recognized
        error('Input %0.f is not a recognized dimension name. See dash.dimensionNames for a list of data dimension names.', v);
    elseif ismember(d, usedDims)
        error('Dimension name "%s" is specified multiple times.', varargin{v});
    end
    usedDims((v+1)/2) = d;
end

% Error check the input metadata values
for v = 2:2:nargin
    value = varargin{v+1};
    
    % Types, matrix, NaN, Inf, NaT
    if ~gridfile.ismetadatatype( value )
        error('The %s metadata must be one of the following datatypes: numeric, logical, char, string, cellstring, or datetime', varargin{v-1});
    elseif ~ismatrix( value )
        error('The %s metadata is not a matrix.', varargin{v-1} );
    elseif isnumeric( value ) && any(isnan(value(:)))
        error('The %s metadata contains NaN elements.', varargin{v-1} );
    elseif isnumeric( value) && any(isinf(value(:)))
        error('The %s metadata contains Inf elements.', varargin{v-1} );
    elseif isdatetime(value) && any( isnat(value(:)) )
        error('The %s metadata contains NaT elements.', varargin{v-1} );
    end
    
    % Warn user if the metadata is a row vector. They probably meant to use
    % a column vector.
    if isrow(value) && ~isscalar(value)
        warning('The %s metadata is a row vector and will be used for a single %s element.', varargin{v-1}, varargin{v-1});
    end
    
    % Prevent duplicates. Need to convert cellstring to string to use
    % unique with the rows option.
    if iscellstring(value)
        value = string(value);
    end
    if size(value,1) ~= size(unique(value,'rows'),1)
        error('The %s metadata contains duplicate rows.', varargin{v-1});
    end
    
    % Add to the output metadata structure
    meta.(varargin{v-1}) = value;
end

end