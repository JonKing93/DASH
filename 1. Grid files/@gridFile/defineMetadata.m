function[meta] = defineMetadata( varargin )
% Creates a structure to define the metadata of a gridded dataset.
%
% meta = gridFile.defineMetadata( dimName1, dimMeta1, ..., dimNameN, dimMetaN )
%
% ----- Inputs -----
%
% dimN: The name of the Nth input dimension. See getDimIDs.m for a
%       list of recognized dimensions. A string.
%
% valN: The metadata for the Nth input dimension. Must be a numeric,
%       logical, char, string, cellstring, or datetime. Cannot have more
%       than 2 dimensions.
%       Each *ROW* will be treated as the metadata for one element.
%
% ----- Outputs -----
%
% meta: The metadata structure for the inputs.

% Check that the number of metadata elements is even
nDim = nargin /2;
if mod(nDim,1)~=0
    error('There must be exactly one set of metadata values for each metadata dimension.');
end

% Initialize values
metaDim = NaN( nDim, 1 );
dimID = getDimIDs;
meta = struct();

% Cycle through the pairs of inputs
for v = 1:2:nargin
    
    % Check the odd elements are non-duplicate dimension IDs
    [isdim, d] = ismember( varargin{v}, dimID );
    if ~isdim
        error('Input %0.f is not a recognized dimension ID.', v);
    elseif ismember( d, metaDim )
        error('Metadata for dimension %s is provided multiple times.', varargin{v} );
    else
        metaDim((v+1)/2) = d;
    end
    
    % Check that the even elements are valid non-duplicate metadata. Save to structure.
    % Warn user about row vectors. Convert cellstring to string
    value = varargin{v+1};
    if ~gridFile.ismetadatatype( value )
        error('The %s metadata must be one of the following datatypes: numeric, logical, char, string, cellstring, or datetime', varargin{v});
    elseif ~ismatrix( value )
        error('The %s metadata is not a matrix.', varargin{v} );
    elseif isnumeric( value ) && any(isnan(value(:)))
        error('The %s metadata contains NaN elements.', varargin{v} );
    elseif isnumeric( value) && any(isinf(value(:)))
        error('The %s metadata contains Inf elements.', varargin{v} );
    elseif isdatetime(value) && any( isnat(value(:)) )
        error('The %s metadata contains NaT elements.', varargin{v} );
    end
    if isrow( value ) && ~isscalar(value) && ~ischar(value)
        warning('The %s metadata is a row vector and will be used for a single %s index.', varargin{v}, varargin{v} );
    end
    if size(value,1) ~= size( unique(value, 'rows'), 1 )
        error('The %s metadata contains duplicate values.', varargin{v});
    end
    if iscellstr( value ) %#ok<ISCLSTR>
        value = string( value );
    end
    
    meta.(varargin{v}) = value;
end

end