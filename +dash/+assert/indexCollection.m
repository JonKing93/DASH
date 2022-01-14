function[indices] = indexCollection(indices, nDims, dimLengths, dimNames, header)
%% dash.assert.indexCollection  Throw error if input is not a collection of indices
% ----------
%   indices = dash.assert.indexCollection(indices, nDims)
%   Requires indices to be a cell vector with one element per dimension.
%   Each element must hold a valid vector of indices. If there is a single
%   dimension, also allows indices to be a direct vector of indices. If
%   these requirements are not met, throws an error. If met, returns the
%   indices as a cell vector of sets of linear indices.
%
%   indices = dash.assert.indexCollection(indices, nDims, dimLengths)
%   Also requires each vector of indices to be compatible with a specified
%   dimension length. To be valid, a vector logical indices must match the
%   length of the dimension. For linear indices, the values of individual
%   elements cannot exceed the length of the dimension.
%
%   indices = dash.assert.indexCollection(indices, nDims, dimLengths, dimNames, header)
%   Customize the error messages and IDs.
% ----------
%   Inputs:
%       indices: The input being checked
%       nDims (scalar positive integer): The number of dimensions being indexed
%       dimLengths (vector, positive integers [nDims] | []): The length of each
%           dimension being indexed. If empty, does not check indices
%           against a dimension length.
%       dimNames (string vector [nDims]): The name of each dimension being indexed
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       indices (cell vector [nDims] {vector, linear indices}): The indices
%           for each dimension organized as a cell vector of linear indices.
%
% <a href="matlab:dash.doc('dash.assert.indexCollection')">Documentation Page</a>

% Default
if ~exist('dimLengths','var') || isempty(dimLengths)
    dimLengths = [];
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:indexCollection";
end
if ~exist('dimNames','var') || isempty(dimNames)
    dimNames = strings(1,nDims);
end

% Parse cell vs single set of indices
name = 'indices';
[indices, wasCell] = dash.parse.inputOrCell(indices, nDims, name, header);

% Check the indices for each dimension
for d = 1:nDims
    noname = strcmp(dimNames(d), "");
    if noname
        dim = sprintf("indexed dimension %.f", d);
    else
        dim = sprintf('the "%s" dimension', dimNames(d));
    end
    if wasCell
        name = sprintf('Indices for %s', dim);
    end
    lengthName = sprintf('the length of %s', dim);

    % Get the length
    length = [];
    if ~isempty(dimLengths)
        length = dimLengths(d);
    end

    indices{d} = dash.assert.indices(indices{d}, length, name, lengthName, [], header);
end

end