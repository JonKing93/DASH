function[] = incompleteEnsembleWarning(obj, vars, nMembers, nNew, header)

name = 'coupled variables';
if numel(vars)==1
    name = 'variable';
end

vars = obj.variables(vars);
vars = dash.string.list(vars);

id = sprintf('%s:incompleteEnsemble', header);
warning(id, ['You requested %.f ensemble members but only %.f ensemble members ',...
    'could be found for %s %s. Continuing build with %.f ensemble members.'],...
    nMembers, nNew, name, vars, nNew);

end