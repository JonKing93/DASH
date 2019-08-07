function[] = notifySecondaryCoupling( obj, v, vall )
% v: Initial variable indices.
%
% vall: The total set of variables.

% Get the variables not in the initial list
sv = vall( ~ismember(vall, v) );

% Notify
fprintf(['The variables ', sprintf('%s, ', obj.varName(sv)), '\b\b\n',...
         'are already coupled to ', sprintf('%s, ', obj.varName(v)), '\b\b\n', ...
         'and will also be coupled.\n\n']);
end