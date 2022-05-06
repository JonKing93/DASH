function[rst] = syntax(helpText)
%% build.function.syntax  Formats RST for the function syntax section from function help text
% ----------
%   rst = build.function.syntax(helpText)
%   Extracts function syntaxes and descriptions from function help text and
%   converts them to RST markup.
% ----------
%   Inputs:
%       helpText (char vector): Help text for a function
%
%   Outputs:
%       rst (char vector): Formatted rst for the syntax section of a
%           function RST page.

title = parse.h1(helpText);
signatures = parse.usage(helpText);
links = link.syntax(title, numel(signatures));
rst = format.function.syntax(signatures, links);

end