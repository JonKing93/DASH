function[obj] = rename(obj, newName)
%% Renames an ensemble object
%
% obj = obj.rename(newName)
%
% ----- Inputs -----
%
% newName: The new name for the ensemble object. A string.
%
% ----- Outputs -----
%
% obj: The updated ensemble object

obj.name = dash.assertStrFlag(newName, 'newName');

end