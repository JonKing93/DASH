function[name] = name(header, istitle)
%% parse.name  Extract the short name of an item
% ----------
%   name = parse.name(helpText)
%   Extracts the short name of an item from its help text.
%
%   name = parse.name(title, true)
%   Extracts the short name of an item from its dot-indexing title.
% ----------
%   Inputs:
%       helpText (char vector): Help text for an item
%       title (string scalar): The dot-indexing title of an item
%
%   Outputs:
%       name (string scalar): The short name of an item. This is the
%           dot-indexing title with all containing packages removed.

% Default
if ~exist('istitle','var') || isempty(istitle)
    istitle = false;
end

% Extract title if a full header
if ~istitle
    title = parse.h1(header);
else
    title = header;
end

% Split off the name
titleParts = split(title, {'.','/'});
name = string( titleParts(end) );

end