function[obj] = resetMeans(obj, varNames)
% Resets options for means for specified variables.
%
% obj = obj.resetMeans(varNames)
%
% ----- Inputs -----
%
% varNames: The names of variables for which mean options should be reset.
%    A string vector or cellstring vector.
%
% ----- Outputs -----
%
% obj: The updated stateVector object.

% Error check, variable index
v = obj.checkVariables(varNames);

% Update each variable
for k = 1:numel(v)
    obj.variables(v(k)) = obj.variables(v(k)).resetMeans;
end

end