function[d] = dimensionIndex(obj, dims)
%% Returns the indices of dimensions in a stateVectorVariable. Returns an
% error if any dimensions do not exist.
%
% d = obj.dimensionIndex(dims)
%
% ----- Inputs -----
%
% dims: A list of dimension names. A string vector or cellstring vector
%
% ----- Outputs -----
%
% d: The indices in the stateVectorVariable dims array

listName = sprintf('dimension in the .grid file for the %s variable', obj.name);
d = dash.checkStrsInList(dims, obj.dims, 'dims', listName);

end