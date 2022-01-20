function[indices] = additiveIndexCollection(indices, nDims, dimNames, header)
%% dash.assert.additiveIndexCollection  Throw error if input is not a collection of additive indices
% ----------
%   dash.assert.additiveIndexCollection(indices, nDims)
%   Requires indices to be a cell vector with one element per dimension.
%   Each element must hold a vector of integers. If there is a single
%   dimension, also allows indices to be a direct vector of integers. If
%   these requirements are not met, throws an error.
%
%   dash.assert.additiveIndexCollection(indices, nDims, dimNames, header)
%   Customize thrown error messages and IDs.
% ----------
%   Inputs:
%       indices: The input being checked
%       nDims (scalar positive integer): The number of dimensions being indexed
%       dimNames (string vector [nDims]): The name of each dimension being indexed
%       header (string scalar): Header for thrown error IDs.
%
% <a href="matlab:dash.doc('dash.assert.additiveIndexCollection')">Documentation Page</a>

% Defaults
if ~exist('dimNames','var') || isempty(dimNames)
    dimNames = strings(1,nDims);
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:additiveIndexCollection";
end

% Parse cell vs single set of indices
[indices, wasCell] = dash.parse.inputOrCell(indices, nDims, 'indices', header);

% Get the name of each set of indices
for d = 1:nDims
    name = dash.string.indexedDimension(dimNames(d), d, wasCell);

    % Check the indices are a vector of integers
    dash.assert.vectorTypeN(indices{d}, 'numeric', [], name, header);
    dash.assert.integers(indices{d}, name, header);
end

end