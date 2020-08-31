function[obj] = remove(obj, varNames)
%% Removes specified variables from a state vector
%
% obj = obj.remove(varNames)
%
% ----- Inputs -----
%
% varNames: The names of the variables that should be removed. A string
%    vector or cellstring vector.
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Error check, variable index
v = obj.checkVariables(varNames);

% Remove each variable from the array
v = sort(v);
for k = numel(v):-1:1
    obj.variables(v(k)) = [];
    obj.coupled(v(k), :) = [];
    obj.coupled(:, v(k)) = [];
    obj.autoCouple(v(k)) = [];
end

end