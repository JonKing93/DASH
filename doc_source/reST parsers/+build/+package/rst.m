function[rst] = rst(title)
%% build.package.rst  Format RST text from the Contents.m help text of a package
% ----------
%   rst = build.package.rst(title)
%   Loads the help text for a package from its Contents file, and formats
%   it into RST.
% ----------
%   Inputs:
%       title (string scalar): The dot-indexing title of the package
%
%   Outputs:
%       rst (char vector): Formatted RST for the package documentation page

% Get the help text, remove everything below the doc link
try
    help = get.help(title);
    help = get.aboveLink(help);

    % Build file parts
    description = build.package.description(help);
    contents = build.package.content(help);

% Report error causes
catch cause
    ME = MException('package:rst', 'Could not build RST for package "%s"', title);
    cause = addCause(cause, ME);
    rethrow(cause);
end

% Join into rst
rst = strcat(description, contents);

end
