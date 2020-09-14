function[obj] = rename(obj, name)
%% Changes the identifying name of the state vector
%
% obj = obj.rename(name)
% Changes the vector's name.
%
% ----- Input -----
%
% name: The new name for the state vector. A string scalar or character row
%    vector.
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Error check. Change name. Use string internally.
dash.assertStrFlag(name, 'name');
obj.name = string(name);

end