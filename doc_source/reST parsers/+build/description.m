function[rst] = description(header)
%% Markup the description section from function help text
% ----------
%   rst = build.description(header)
% ----------
%   Inputs:
%       header (char vector): Function help text
%
%   Outputs:
%       rst (string scalar): reST markup for the description section

% Get the usage information and title
[signatures, details] = parse.usage(header);
title = parse.title(header);

% Get the syntax links, as well as links to signature inputs and outputs
links = link.syntax(title, numel(signatures));
signatures = link.signatureArgs(signatures, title);

% Format
rst = format.description(links, signatures, details);

end

