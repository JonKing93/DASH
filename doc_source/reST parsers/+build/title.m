function[rst] = title(header)
%% Markup the page title from function help text
% ----------
%   rst = build.title(header)
% ----------
%   Inputs:
%       header (char vector): Function help text
%
%   Outputs:
%       rst (string scalar): reST markup for title

[title, description] = parse.title(header);
rst = format.title(title, description);

end