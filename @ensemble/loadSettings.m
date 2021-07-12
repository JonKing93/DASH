function[members, v] = loadSettings(obj)
%% Gets the ensemble members and variables to load. Checks that user-specified
% options are still consistent with the .ens file.
%
% [members, v] = obj.loadSettings;
%
% ----- Outputs -----
%
% members: A set of linear indices specifying which ensemble members to
%    load
%
% v: Variable indices to load.

% Get the object settings
members = obj.members;
variables = obj.variables;

% Check the variables are still consistent with the .ens file
filevars = obj.metadata.variableNames;
[infile, v] = ismember(variables, filevars);
if any(~infile)
    bad = find(~infile, 1);
    missingVariableError(variables(bad), filevars, obj.file);
end

% Check the ensemble members are still consistent
[~, nEns] = obj.metadata.sizes;
if max(members) > nEns
    notEnoughMembersError(max(members), nEns, obj.file);
end

% Return the variable indices in sorted order
v = sort(v);

end

% Long error messages
function[] = notEnoughMembersError(maxRequested, nEns, file)
error(['You previously requested to load ensemble member %.f. However, ',...
    'the data in file "%s" appears to have changed and now only has %.f ',...
    'ensemble members. You may want to use the "loadMembers" command again.'], ...
    maxRequested, file, nEns);
end
function[] = missingVariableError(requested, vars, file)
bad = find(~ismember(requested, vars), 1);
error(['You previously requested to load data for variable "%s". However, ',...
    'the data in file "%s" appears to have changed and no longer contains ',...
    'this variable. Currently, the variables in the file are: %s. You may ',...
    'want to use the "loadVariables" command again.'], ...
    requested(bad), file, dash.string.messageList(vars));
end