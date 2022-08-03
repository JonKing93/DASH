function[text] = aboveLink(helpText)
%% get.aboveLink  Get help text above the documentation link
% ----------
%   text = get.aboveLink(helpText)
%   Returns all help text above the final documentation link.
% ----------
%   Inputs:
%       helpText (char vector): Help text for an item
%
%   Outputs:
%       text (char vector): The text above the documentation link.

% Determine the title of the item
title = parse.h1(helpText);

% Locate the documentation link
doclink = sprintf('\n%% <a href="matlab:dash.doc(''%s'')">Documentation Page</a>', title);
linkIndex = strfind(helpText, doclink);
nLink = numel(linkIndex);

% Check for newlines following the link
eol = find(helpText==10);
eolAfterLink = eol(eol>linkIndex);

% Throw error if there are no links, more than one link, or the link is not
% the final line of help text
if nLink==0
    error('The help text is missing the documentation link');
elseif nLink>1
    error('The help text has multiple documentation links');
elseif numel(eolAfterLink)>1
    error('The documentation link is not the final line of the help text');
end

% Get the text
text = helpText(1:linkIndex-1);

end