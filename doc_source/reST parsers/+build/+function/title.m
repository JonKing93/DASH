function[rst] = title(helpText)
%% build.function.title  Format the RST page title from function help text
% ----------
%   rst = build.function.title(helpText)
%   Extracts function title information from help text and formats into RST
% ----------
%   Inputs:
%       helpText (char vector): Function help text
%
%   Outputs:
%       rst (char vector): Formatted RST for the page title

[title, description] = parse.h1(helpText);
rst = format.function.title(title, description);

end