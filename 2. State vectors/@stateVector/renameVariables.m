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

% Error check, variable names
v = obj.checkVariables(varNames);

% Error check the new names
dash.assertStrList(newNames, 'newNames');
newNames = string(newNames);
dash.assertVectorTypeN(newNames, [], numel(v), 'newNames');

% Check there are no naming conflicts
names = obj.variableNames;
names(v) = newNames;
if numel(names) < numel(unique(names))
    bad = find(~ismember(1:numel(names), loc), 1);
    error('Cannot rename because there would be multiple variables named %s.', names(bad));
end

% Check names are valid Matlab variables
if any(~isvarname(newNames))
    bad = find(~isvarname(newNames),1);
    error(['Element %.f of newNames (%s) is not a valid MATLAB variable name. ', ...
        'Valid names start with a letter and include only letters, numbers, ',...
        'and underscores.'], bad, newNames(bad));
end

% Rename
for k = 1:numel(v)
    obj.variables(v(k)) = obj.variables(v(k)).rename( newNames(k) );
end
    
end