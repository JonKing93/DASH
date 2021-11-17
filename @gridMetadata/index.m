function[obj] = index(obj, dimensions, indices, varargin)
%% gridMetadata.index  Return dimensional metadata at specified indices
% ----------
%   obj = <strong>obj.index</strong>(dimensions, indices)
%   Returns a gridMetadata object in which the metadata along the specified
%   dimensions corresponds to the metadata at the associated indices.
%   Indices are for the rows of metadata in the original gridMetadata
%   object.
%
%   obj = <strong>obj.index</strong>(dimension1, indices1, dimension2, indices2, .., dimensionN, indicesN)
%   Uses a Name,Value syntax to index dimensions.
% ----------
%   Inputs:
%       dimensions (string vector [nDims]): The names of the dimensions
%           that should be indexed. Can only include dimensions that are
%           defined in the gridMetadata object.
%       indices (cell vector [nDims] {vector, linear indices | logical vector [dimension length]}:
%           The indices of metadata rows to return along the specified
%           dimensions. Should be a cell vector with one cell per named
%           dimension. Each cell holds a vector of indices for the
%           associated dimension. Indices can either be a set of linear
%           indices, or a logical vector the length of the dimension.
%       dimensionN (string scalar): The name of a dimension to index
%       indicesN (vector, linear indices | logical vector [dimension length]):
%           The indices of the metadata rows to return along dimension N.
%           Either a set of linear indices, or a logical vector the length
%           of dimension N.
% 
%   Outputs:
%       obj (gridMetadata object): The updated metadata. Has the indexed
%           rows of metadata along the input dimensions.
%
% <a href="matlab:dash.doc('gridMetadata.index')">Documentation Page</a>

% Error header
header = "DASH:gridMetadata:index";
obj.assertScalar(header);

% Parse and error check
if numel(varargin)>0
    varargin = [{dimensions}, {indices}, varargin];
    extraInfo = 'Inputs must be Dimension-Name,Indices pairs.';
    [dims, indices] = dash.assert.nameValue(varargin, 0, extraInfo, header);
else
    dims = dash.assert.strlist(dimensions, 'dimensions', header);
end

% Require defined, non-duplicate dimensions
defined = obj.defined;
dash.assert.strsInList(dims, defined, 'Dimension name', 'dimension defined in the metadata', header);
dash.assert.uniqueSet(dims, 'Dimension name', header);
nDims = numel(dims);

% Parse and error check indices
dimLengths = NaN(1, nDims);
for d = 1:nDims
    dimLengths(d) = size(obj.(dims(d)),1);
end
indices = dash.assert.indexCollection(indices, nDims, dimLengths, dims, header);

% Build the indexed metadata
newMeta = cell(1, nDims);
for d = 1:nDims
    newMeta{d} = obj.(dims(d))(indices{d}, :);
end

% Update the object
dims = cellstr(dims(:))';
nameValue = [dims; newMeta];
obj = obj.edit(nameValue{:});

end