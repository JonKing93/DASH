function[obj] = extract(obj, varNames)
%% Restricts ensemble metadata to a set of specified variables.
%
% obj = obj.extract(varNames)
%
% ----- Inputs -----
%
% varNames: The names of the variables that should be in the ensemble
%    metadata. A string vector or cellstring vector.
%
% ----- Outputs -----
%
% obj: The updated ensembleMetadata object.

% Error check, variable indices
v = dash.checkStrsInList(varNames, obj.variableNames, 'varNames', 'variable in the state vector');

% Get the variables to remove
allVars = 1:numel(obj.variableNames);
remove = allVars(~ismember(allVars, v));

% Update
names = obj.variableNames;
obj = obj.remove( names(remove) );

end