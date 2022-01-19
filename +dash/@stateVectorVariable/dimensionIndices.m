function[d] = dimensionIndices(obj, dimensions, header)
%% dash.stateVectorVariable.dimensionIndices  Parse the indices of dimensions in a state vector variable
% ----------
%   d = obj.dimensionIndices(dimensions)
%   Return the indices of the specified dimensions in a state vector
%   variable. Throws an error if a dimension is unrecognized.
%
%   d = obj.dimensionIndices(dimensions, header)
%   Customize thrown error IDs.
% ----------
%   Inputs:
%       dimensions (string vector): Names of dimensions in the variable
%       header (string scalar): Header for thrown error IDs.
%  
%   Outputs:
%       d (vector, linear indices): The indices of the specified dimensions
%           in the state vector variable.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.dimensionIndices')">Documentation Page</a>

% Header
if ~exist('header','var') || isempty(header)
    header = "DASH:stateVectorVariable:dimensionIndices";
end

% Parse the dimension names
listName = 'dimension of the variable';
d = dash.assert.strsInList(dimensions, obj.dims, 'Dimension', listName, header);

end