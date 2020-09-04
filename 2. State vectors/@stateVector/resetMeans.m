function[obj] = resetMeans(obj, varNames, dims)
% Resets options for means for specified variables and dimensions.
%
% obj = obj.resetMeans
% Resets mean options for all variables and dimensions
%
% obj = obj.resetMeans(varNames)
% Resets mean options in all dimensions for specified variables.
%
% obj = obj.resetMeans(varNames, dims)
% Resets mean options for the specified dimensions. 
%
% ----- Inputs -----
%
% varNames: The names of variables for which mean options should be reset.
%    A string vector or cellstring vector.
%
% dims: The names of dimensions in which to reset mean options. A string
%    vector or cellstring vector.
%
% ----- Outputs -----
%
% obj: The updated stateVector object.

% Default and error check variables. Get indices
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
    obj.variables(v(k)) = obj.variables(v(k)).resetMeans(dims);
end

end