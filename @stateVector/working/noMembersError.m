function[] = noMembersError(obj, vars, header)

name = 'coupled variables';
if numel(vars)==1
    name = 'variable';
end

vars = obj.variables(vars);
vars = dash.string.list(vars);

id = sprintf('%s:noMembersFound', header);
error(id, 'Could not find any new ensemble members for %s %s.', name, vars);

end