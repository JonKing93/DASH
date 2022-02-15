function[d] = dimensionIndices(obj, dimensions)
%% dash.stateVectorVariable.dimensionIndices  Return indices of dimensions within a state vector variable
% ----------
%   d = <strong>obj.dimensionIndices</strong>(dimensions)
%   Returns the indices of the listed dimensions within the variable. The
%   index of each dimension is the index of the design parameters for the
%   dimension within the variable's design properties. Indices are in the
%   same order in which the dimensions were listed. If a listed dimension
%   is not in the variable, returns an index of 0.
% ----------
%   Inputs:
%       dimensions (string vector [nDims]): A list of dimension names.
%
%   Outputs:
%       d (vector, linear indices [nDims]): The index of each listed dimension
%           within the variable. Uses an index of 0 for dimensions that are
%           not in the variable.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.dimensionIndices')">Documentation Page</a>

[~, d] = ismember(dimensions, obj.dims);

end