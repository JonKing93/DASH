function[] = notEnoughMembersError(obj, vars, nMembers, nNew, nRemaining, header)

name = 'coupled variables';
if numel(vars)==1
    name = 'variable';
end

vars = obj.variables(vars);
vars = dash.string.list(vars);

nTotal = nNew + nRemaining;

id = sprintf('%s:notEnoughMembers', header);
error(id, ['Cannot find enough new members to complete the ensemble. You have ',...
    'requested %.f ensemble members, but only %.f ensemble members could',...
    'be found for %s %s.'], nMembers, nTotal, name, vars);
end