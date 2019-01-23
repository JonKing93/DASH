function[design, rv] = unrelateVars( design, v, xv, field, nowarn )
%
% design = unrelateVars( design, v, xv, field, nowarn )
% Removes a relationship between variables and 1. a template variable, 2.
% all secondary template variables.

% Error check
if ~isscalar(xv)
    error('template must be a single variable.');
elseif ismember(xv, v)
    error('The template cannot be in the list of variables.');
elseif ~islogical(nowarn) || ~isscalar(nowarn)
    error('nowarn must be a logical scalar.');
elseif ~ismember(field, {'isCoupled','isSynced'})
    error('field must be ''isCoupled'' or ''isSynced''');
end

% Get all secondary template variables
sv = find( design.(field)(v,:) );

% Get the set of all variables from which to remove the relationship
rv = [xv, sv];

% For each variable having a relationship removed...
nVar = numel(v);
for k = 1:nVar
    
    % Get the remove variables that are not the variable itself
    rvCurr = rv( rv~=v(k) );
    
    % Unmark the relationship
    design.(field)([v, rvCurr]) = false;
    design.(field)([rvCurr, v]) = false;
end

end