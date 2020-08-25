function[obj] = design(obj, varName, dim, type, indices)
%% Designs a dimension of a variable in a state vector.
%
% obj = obj.design( varName, dim, type )
% Specify whether a dimension of a state vector variable is a state
% dimension or an ensemble dimension.
%
% obj = obj.design( varName, dim, 'state', stateIndices )
% Marks a dimension of a state vector variable as a state dimension.
% Specifies the indices of required data along this dimension in the 
% variable's .grid file.
%
% obj = obj.design( varName, dim, 'ensemble', ensIndices )
% Marks a dimension of a state vector variable as an ensemble dimension.
% Specifies the reference indices of required data along this dimension in
% the variable's .grid file.
%
% ----- Inputs -----
%
% varName: The name of a variable in the state vector. A string.
%
% dim: The name of one of the variable's dimensions. A string.
%
% type: A string indicating the type of the dimension. Either 'state' or
%    'ensemble'.
%
% stateIndices: The indices of required data along the dimension in the
%    variable's .grid file. Either a vector of linear indices or a logical
%    vector the length of the dimension.

% Error check the variable names. Get the variable index
dash.assertStrFlag(varName, 'varName');
v = obj.variableIndex(varName);

% Default for indices
if ~exist('indices','var')
    indices = [];
end

% Update the state vector variable
obj.variables(v) = obj.variables(v).design(dim, type, indices);

end
% 
% % Initial error checking
% dash.assertStrFlag(varName, 'varName');
% dash.assertStrFlag(dim, 'dim');
% dash.assertStrFlag(type, 'type');
% 
% % Check that the variable and dimension exist. Get their indices.
% v = obj.variableIndex(varName);
% d = obj.dimensionIndex(v, dim);
% 
% % Check that type is recognized and get the name of the indices
% if strcmpi(type, "state")
%     name = 'stateIndices';
% elseif strcmpi(type,"ensemble")
%     name = 'ensIndices';
% else
%     error('type must either be "state" or "ensemble"');
% end
% 
% % Default for indices and error check
% if ~exist('indices','var') || isempty(indices)
%     indices = 1:obj.variables(v).size(d);
% end
% indices = dash.checkIndices(indices, name, obj.variable(v).size(d), obj.variable(v).dims(d));
% 
% % State dimension
% if strcmpi(type, 'state')
%     obj.variables(v).isState(d) = true;
%     obj.variables(v).stateIndices{d} = indices;
%     
%     % Reset ensemble properties
%     obj.variables(v).ensIndices{d} = [];
%     
% % Ensemble dimension
% else
%     obj.variables(v).isState(d) = false;
%     obj.variables(v).ensIndices{d} = indices;
%     
%     % Reset state properties
%     obj.variables(v).stateIndices{d} = indices;
% end
% 
% end
%     
%     