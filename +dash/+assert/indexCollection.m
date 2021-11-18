function[indices] = indexCollection(indices, nDims, dimLengths, dimNames, header)
%% dash.assert.indexCollection  Throw error if input is not a collection of indices
% ----------
%   indices = dash.assert.indexCollection(indices, nDims, dimLengths)
%   Requires indices to either be a cell vector with one element per
%   dimension (allows a direct vector of indices if there is a single
%   dimension). Each cell must hold a valid vector of logical or linear
%   indices for the dimension. If these requirements are not met, throws an
%   error. If met, returns the indices as a cell vector of sets of linear
%   indices.
%
%   indices = dash.assert.indexCollection(indices, nDims, dimLengths, dimNames, header)
%   Customize the header in thrown error IDs.
% ----------
%   Inputs:
%       indices: The input being checked
%       nDims (scalar positive integer): The number of dimensions being indexed
%       dimLengths (vector, positive integers [nDims]): The length of each
%           dimension being indexed.
%       dimNames (string vector [nDims]): The name of each dimension being indexed
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       indices (cell vector [nDims] {vector, linear indices}): The indices
%           for each dimension organized as a cell vector of linear indices.
%
% <a href="matlab:dash.doc('dash.assert.indexCollection')">Documentation Page</a>

% Default
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

    indices{d} = dash.assert.indices(indices{d}, dimLengths(d), name, lengthName, [], header);
end

end