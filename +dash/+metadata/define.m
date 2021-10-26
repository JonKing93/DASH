function[meta] = define(varargin)
%% dash.metadata.define  Creates a metadata structure for a gridded dataset
% ----------
%   meta = dash.define.metadata(dim1, meta1, dim2, meta2, ..., dimN, metaN)
%   Returns a metadata structure for a gridded dataset
% ----------
%   Inputs:
%       dimN (string scalar): The name of a dimension of a gridded dataset
%       metaN (matrix - numeric | logical | char | string | cellstring |
%           datetime): The metadata for the dimension. Cannot have NaN or
%           NaT elements. All rows must be unique.
%
%   Outputs:
%       meta (scalar structure): The metadata structure for a gridded
%           dataset. The fields of the structure are the input dimension
%           names (dimN). Each field holds the associated metadata 
%           field (metaN). Cellstring metadata are converted to string.
%
%   Throws:
%       DASH:metadata:define:oddNumberOfInputs  if an odd number of inputs
%           are passed to the function
%       DASH:metadata:define:repeatedDimension  if a dimension name
%           repeated in the inputs
%       DASH:metadata:define:invalidDimensionName  if a dimension name is
%           not a valid MATLAB variable name
%       (Warning) DASH:metadata:define:metadataFieldIsRow  if a metadata
%           field is a row vector
%   
%   <a href="matlab:dash.doc('dash.metadata.define')">Documentation Page</a>

% Header for error IDs
header = "DASH:metadata:define";

% Require an even number of inputs
nDim = nargin / 2;
if mod(nDim,1)~=0
    id = sprintf('%s:oddNumberOfInputs', header);
    error(id, ['There must be an even number of inputs. ',...
        '(One metadata matrix for each dimension name)']);
end

% Track dimensions and initialize output
userDims = strings(nDim,1);
meta = struct();

% Prevent duplicate dimension names
for v = 1:2:nargin-1
    dim = dash.assert.strflag(varargin{v}, sprintf("Input %.f",v), header);
    if ismember(varargin{v}, userDims)
        id = sprintf('%s:repeatedDimension', header);
        error(id, 'Dimension name "%s" is listed multiple times', dim);
    end
    
    % Require valid variable names
    if ~isvarname(dim)
        id = sprintf('%s:invalidDimensionName', header);
        error(id, ['Input %.f ("%s") is not a valid dimension name. ',...
            'Dimension names must begin with a letter, can only include ',...
            'letters, digits, and underscores, and cannot be a MATLAB keyword.'],...
            v, dim);
    end
    
    % Require valid metadata. Warn user about row vectors if they probably
    % meant to use a column vector
    value = dash.metadata.assertField(varargin{v+1}, dim, header);
    if isrow(value) && ~isscalar(value)
        id = sprintf('%s:metadataFieldIsRow', header);
        warning(id, ['The %s metadata is a row vector and will be used for ',...
            'a single element along the dimension'], dim);
    end
    
    % Add to output
    meta.(dim) = value;
end

end