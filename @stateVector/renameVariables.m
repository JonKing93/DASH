function[obj] = renameVariables(obj, varNames, newNames)
%% Changes the names of specified variables
%
% obj = obj.renameVariables(varNames, newNames)
%
% ----- Inputs -----
%
% varNames: The current names of the variables being renamed. A string
%    vector or cellstring vector.
%
% newNames: The new names of the variables. A string vector or cellstring
%    vector with one element for each variable in varNames. Must be in the
%    same order as varNames.
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Error check, variable names, editable
obj.assertEditable;
v = obj.checkVariables(varNames);

% Error check the new names
dash.assertStrList(newNames, 'newNames');
newNames = string(newNames);
dash.assertVectorTypeN(newNames, [], numel(v), 'newNames');

% Check there are no naming conflicts and names are valid
obj.checkVariableNames(newNames, v, 'newNames', 'rename variables for');

% Rename
for k = 1:numel(v)
    obj.variables(v(k)) = obj.variables(v(k)).rename( newNames(k) );
end
    
end