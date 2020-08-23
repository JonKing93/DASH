function[] = notifySecondaryCoupling( obj, v, vall )
% Alert user if unnamed variables are automatically coupled
% v: Initial variable indices.
%
% vall: The total set of variables.

% Get the variables not in the initial list
sv = vall( ~ismember(vall, v) );

% Notify if additional variables are to be coupled
if ~isempty(sv)
    s = "s";
    verb = "are";
    if numel(sv) == 1
        s = "";
        verb = "is";
    end

    % Notify
    fprintf([sprintf('The variable%s ',s), sprintf('"%s", ', obj.varName(sv)), '\b\b\n',...
             sprintf('%s already coupled to ',verb), sprintf('"%s", ', obj.varName(v)), '\b\b\n', ...
             'and will also be coupled.\n\n']);
end

end