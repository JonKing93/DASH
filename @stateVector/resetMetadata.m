function[obj] = resetMetadata(obj, varNames, dims)
% Resets metadata options for specified variables and dimensions.
%
% obj = obj.resetMetadata
% Resets metadata options for all variables and dimensions
%
% obj = obj.resetMetadata(varNames)
% Resets metadata options in all dimensions for specified variables.
%
% obj = obj.resetMetadata(varNames, dims)
% Resets metadata options for the specified dimensions. 
%
% ----- Inputs -----
%
% varNames: The names of variables for which metadata options should be reset.
%    A string vector or cellstring vector.
%
% dims: The names of dimensions in which to reset metadata options. A string
%    vector or cellstring vector.
%
% ----- Outputs -----
%
% obj: The updated stateVector object.

% Default and error check variables. Get indices. Check editable.
obj.assertEditable;
if ~exist('varNames','var') || isempty(varNames)
    v = 1:numel(obj.variables);
else
    v = obj.checkVariables(varNames);
end

% Default for dims
if ~exist('dims','var') || isempty(dims)
    dims = [];
end

% Update each variable
for k = 1:numel(v)
    obj.variables(v(k)) = obj.variables(v(k)).resetMetadata(dims);
end

end