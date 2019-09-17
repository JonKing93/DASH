function[] = notifySecondaryOverlap( obj, v, vall, tf )

% v: Initial variable indices
%
% vall: Total set of variables
%
% tf: Whether to permit or forbid overlap

% Get the variables not in the initial list
sv = vall( ~ismember(vall, v) );

% Notify if additional variables have overlap adjusted
if ~isempty(sv)
    s = "s";
    verb = "are";
    if numel(sv) == 1
        s = "";
        verb = "is";
    end

    if tf
        type = "allow";
    else
        type = "forbid";
    end

    % Notify
    fprintf([sprintf('The variable%s ',s), sprintf('"%s", ', obj.varName(sv)), '\b\b\n',...
             sprintf('%s coupled to ',verb), sprintf('"%s", ', obj.varName(v)), '\b\b\n', ...
             sprintf('and will also be updated to %s overlap.\n\n', type)   ]);
end

end