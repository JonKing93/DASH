function[] = checkVariableNames(obj, newNames, v, inputName, methodName)
%% Checks that new variable names are valid and do not duplicate names
% already in the state vector.
%
% obj.checkVariableNames(newNames, v, inputName, methodName)
% 
% ----- Inputs -----
%
% newNames: The new variable names. A string vector or cellstring vector.
%
% v: The variable indices of the new names. If empty, uses end+1
%
% inputName: The name of the input. Used for error messages.
%
% methodName: The name of the action being attempted.

% Default index for the new names
if isempty(newNames)
    v = numel(obj.variables)+(1:numel(newNames));
end

% Check that the new names are valid MATLAB variable names
if any(~isvarname(newNames))
    bad = find(~isvarname(newNames),1);
    str = sprintf('The value of %s (%s)', inputName, newNames);
    if numel(newNames)>1
        str = sprintf('Element %.f of %s (%s)', bad, inputName, newNames(bad));
    end
    error(['%s is not a valid MATLAB variable name. Valid names must start ',...
        'with a letter and may only include letters, numbers, and underscores.'], str);
end

% Combine new names with old
names = obj.variableNames;
names(v) = newNames;

% Check for duplicates
[uniqNames, loc] = unique(names);
nNames = numel(names);
if nNames < numel(uniqNames)
    bad = find(~ismember(1:nNames, loc), 1);
    error(['Cannot %s %s because there would be multiple variables named "%s".', ...
        'If you want to change existing variable names, see "stateVector.renameVariable".'],...
        methodName, obj.errorTitle, names(bad));
end

end