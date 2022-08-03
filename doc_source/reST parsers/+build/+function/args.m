function[rst] = args(header, commentName, linkType, rstName)
%% Markup the Inputs or Outputs section from function help text
% ----------
%   rst = build.args(header, commentName, linkType, rstName)
% ----------
%   Inputs:
%       header (char vector): Function help text
%       commentName (string scalar): Name of the section in the function
%           help text. Usually "Inputs" or "Outputs"
%       linkType (string scalar): The section label to use for reference
%           links. Either "input" or "output"
%       rstName (string scalar): The section header to use in the reST
%           markup. "Input Arguments" or "Output Arguments"
%
%   Outputs:
%       rst (string scalar): reST markup for the section

% Get the inputs and title. Only continue if the parameter is provided
[names, types, details] = parse.parameters(commentName, header);
if isempty(names)
    rst = '';
    return;
end

% Get the links and accordion handles
title = parse.h1(header);
handles = link.handles(linkType, numel(names));
links = link.args(title, linkType, names);

% Format the type lines, then combine with details
types = format.function.types(types);
details = format.function.argDetails(types, details);

% Format the rst
rst = format.function.args(rstName, names, details, links, handles);

end