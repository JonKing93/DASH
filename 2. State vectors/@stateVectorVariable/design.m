function[obj] = design(obj, dim, type, indices)
%% Designs a dimension of a stateVectorVariable
%
% obj = obj.design(dim, type)
%
% obj = obj.design(dim, 'state', stateIndices)
%
% obj = obj.design(dim, 'ensemble', ensIndices)
%
% ----- Inputs -----
%
% dim: The name of one of the variable's dimensions. A string.
%
% type: A string indicating the type of the dimension. Either 'state' or
%    'ensemble'.
%
% stateIndices: The indices of required data along the dimension in the
%    variable's .grid file. Either a vector of linear indices or a logical
%    vector the length of the dimension.

% Error check. Get the dimension index
dash.assertStrFlag(dim, 'dim');
dash.assertStrFlag(type, 'type');
d = obj.dimensionIndex(dim);

% Check that type is recognized and get the name of the indices
if strcmpi(type, "state")
    name = 'stateIndices';
elseif strcmpi(type,"ensemble")
    name = 'ensIndices';
else
    error('type must either be "state" or "ensemble"');
end

% Default for indices and error check
if ~exist('indices','var') || isempty(indices)
    indices = (1:obj.size(d))';
end
indices = dash.checkIndices(indices, name, obj.size(d), obj.dims(d));

% State dimension
if strcmpi(type, 'state')
    obj.isState(d) = true;
    obj.stateIndices{d} = indices;
    
    % Reset ensemble properties
    obj.variables(v).ensIndices{d} = [];
    
% Ensemble dimension
else
    obj.isState(d) = false;
    obj.ensIndices{d} = indices;
    
    % Reset state properties
    obj.stateIndices{d} = indices;
end

end