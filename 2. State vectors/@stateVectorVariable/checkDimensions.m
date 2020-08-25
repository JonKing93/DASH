function[d] = checkDimensions(obj, dims, multiple)
%% Returns the indices of dimensions in a state vector variable. Returns an
% error if any dimensions do not exist. Optionally checks that only a single
% dimension is provided.
%
% d = obj.checkDimensions(dims, multiple)
%
% ----- Inputs -----
%
% dims: A list of dimension names. A string vector or cellstring vector
%
% multiple: A scalar logical. Indicates whether multiple dimensions are
%    allowed as input (true) or just one dimension (false).
%
% ----- Outputs -----
%
% d: The indices in the stateVectorVariable dims array

% Process singular inputs
name = 'dims';
if ~multiple
    name = 'dim';
    dash.assertStrFlag(dims, name);
end

% Check the dimensions are in the variable and get their index
listName = sprintf('dimension in the .grid file for the %s variable', obj.name);
d = dash.checkStrsInList(dims, obj.dims, name, listName);

end