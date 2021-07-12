function[obj] = rename(obj, newName)
%% Changes the identifying ensemble name for the ensembleMetadata object.
%
% obj = obj.rename(newName)
%
% ----- Inputs -----
%
% newName: The new identifying name for the ensemble. A string.
%
% ----- Outputs -----
%
% obj: The updated ensembleMetadata object.

obj.name = dash.assert.strflag(newName, 'newName');

end