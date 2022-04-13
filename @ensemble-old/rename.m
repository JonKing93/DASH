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

% Update name (error checking via ensembleMetadata)
obj.metadata = obj.metadata.rename(name);
obj.name = dash.assert.strflag(newName, 'newName');

end