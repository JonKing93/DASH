function[obj] = uncouple(obj, varNames)
%% Uncouples the specified variables within a state vector.
%
% obj = obj.uncouple(varNames)
%
% ----- Inputs -----
%
% varNames: The names of the variables that should be uncoupled. A string
%    vector or cellstring vector.
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Error check, variable index
v = obj.checkVariables(varNames);

% Uncouple the variables, but keep each variable coupled with itself.
for k = 1:numel(v)
    obj.coupled(v, v(k)) = false;
    obj.coupled(v(k), v) = false;
    obj.coupled(v(k), v(k)) = true;
end

end
