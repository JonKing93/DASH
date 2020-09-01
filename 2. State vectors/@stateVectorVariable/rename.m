function[obj] = rename(obj, newName)
%% Changes the name of a state vector variable
%
% obj = obj.rename(newName)
%
% ----- Inputs -----
%
% newName: The new name of the variable. A string scalar or character row
%    vector.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable

% Change name. Use string internally
obj.name = string(newName);

end