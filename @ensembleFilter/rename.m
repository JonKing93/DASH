function[obj] = rename(obj, name)
%% Renames an ensembleFilter object
%
% obj = obj.rename( name )
%
% ----- Inputs -----
%
% name: The new name. A string.
%
% ----- Outputs -----
%
% obj: The updated ensembleFilter object

obj.name = dash.assertStrFlag(name, 'name');

end