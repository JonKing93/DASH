function[rst] = description(text)
%% build.package.description  Formats RST for the description section of a package from help text
% ----------
%   rst = build.package.description(text)
%   Extracts the description from package help text and formats RST
% ----------
%   Inputs:
%       text (char vector): Help text for a package.
%
%   Outputs:
%       rst (char vector): Formatted RST for the description section

[title, h1] = parse.h1(text);
description = get.description(text);
description = parse.paragraphs(description);
rst = format.package.description(title, h1, description);

end