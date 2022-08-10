function[details] = aboveLink(title, details)
%% get.aboveLink  Returns all text above the documentation link
% ----------
%   details = get.aboveLink(title, details)
%   Given the details section of help text, returns all text above the
%   documentation link. Throws an error if the link is missing or invalid.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of the item
%       details (char vector): The details section of the help text for the item
%
%   Outputs:
%       details (char vector): The portion of the details text above the
%           documentation link through the end-of-line character
%           preceding the documentation link line.

% Locate the documentation link
doclink = sprintf('<a href="matlab:dash.doc(''%s'')">Documentation Page</a>', title);
linkLocation = strfind(details, doclink);
nLink = numel(linkLocation);
if nLink == 0
    error('rst:parser', 'Could not locate the documentation link');
elseif nLink > 1
    error('rst:parser', 'The help text has %.f documentation links, but it can only have 1', nLink);
end

% Determine the line that holds the documentation link
eol = find(details==10);
linkLine = find(eol>linkLocation, 1);
if linkLine == 1
    error('rst:parser', 'The documentation link cannot be on the first line of the details');
end

% Check that the link line is formatted correctly
line = get.line(linkLine, details, eol, 3);
line = char(line);
if line(2)~=' '
    error('rst:parser', 'The documentation link line must begin with a space');
elseif strfind(line, doclink)~=3
    error('rst:parser', 'The doumentation link must begin on the second character of its line');
elseif numel(line)~=numel(doclink)+2
    error('rst:parser', 'The documentation link line has additional characters after the link.');
end

% Extract the details above the link
stop = eol(linkLine-1);
details = details(1:stop);

end