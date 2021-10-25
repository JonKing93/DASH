function[rst] = syntax(header)
%% Markup the Syntax section from function help text
% ----------
%   rst = build.syntax(header)
% ----------
%   Inputs:
%       header (char vector): Function help text
%
%   Outputs:
%       rst (string scalar): reST markup for the Syntax section

signatures = parse.usage(header);
title = parse.title(header);
links = link.syntax(title, numel(signatures));
rst = format.syntax(signatures, links);

end
