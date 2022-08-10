function[h1, description, details] = help(name)
%% get.help  Returns and organizes the help text for an item
% ----------
%   text = get.help(name)
%   Returns the help text for an item.
% ----------
%   Inputs:
%       name (string scalar): The full dot-indexing title of a package,
%           function, class, or method.
%   
%   Outputs:
%       text (char vector): The help text for the item.

% Extract the help text. Throw error if undocumented
text = help(name);
if isempty(text)
    error('rst:parser', 'Could not find the item. It may not be on the active path.');
elseif ~isspace(text(1))
    error('rst:parser', 'The item does not have help text');
end

% Get the end of lines
eol = find(text == 10);

% Extract and error check the H1 line and summary
h1 = getH1(text, eol(1));
h1 = checkH1(h1, name);

% Locate the hline delimiters
hlines = findHlines(text, eol);

% Get and error check the description
if numel(hlines)==1
    description = '';
else
    description = getDescription(text, hlines);
    assert.indented(description, 4, 'the help text');
end

% Get the details
start = hlines(end,2) + 1;
stop = numel(text);
details = text(start:stop);

end

function[h1] = getH1(text, lineEnd)
h1 = text(1:lineEnd-1);
end
function[summary] = checkH1(h1, name)

% Adjust title for abstract methods
if startsWith(h1, ' % ')
    h1 = [' ', h1(3:end)];
end

% Error check the title
titleEnd = 2 + strlength(name);
minLength = titleEnd + 2 + 1;
if numel(h1) < minLength
    error('rst:parser', 'The H1 line is too short');
elseif ~startsWith(h1, '  ')
    error('rst:parser', 'The H1 line must begin with a %% and then a space.');
elseif ~strcmp(h1(3:titleEnd), name)
    error('rst:parser', 'The H1 line does not begin with the title of the item.');
elseif h1(titleEnd+1)~=' ' || h1(titleEnd+2)~=' '
    error('rst:parser', 'The H1 title is not followed by two spaces.');
end

% Extract the summary. Require at least one character of non-whitespace
summary = h1(titleEnd+3:end);
if all(isspace(summary))
    error('rst:parser', 'The H1 line does not include a summary');
end

end
function[hlines] = findHlines(text, eol)

% Locate the hline delimiters
delimiter = sprintf('\n  ----------');
hlineLength = strlength(delimiter);
hlines = strfind(text, delimiter);
nLines = numel(hlines);

% Only allow 1 or 2 hlines
if nLines==0
    error('rst:parser', 'The help text does not have a valid hline.');
elseif nLines>2
    error('rst:parser', 'The help text has %.f hlines, but it cannot have more than 2.', numel(hline));
end

% Locate the end of each hline
lineEnds = NaN(nLines, 1);
for k = 1:numel(hlines)
    lineEnds(k) = eol( find(eol>hlines(k),1) );

    % Check that the line only has whitespace after the dashes
    line = text( hlines(k)+hlineLength:lineEnds(k) );
    if ~all(isspace(line))
        error('rst:parser', 'hline %.f has non-whitespace values after the dashed line.', k);
    end
end

% Return the indices of each hline
hlines = [hlines'+1, lineEnds];

end
function[description] = getDescription(text, hlines)

% Extract the text between the two hlines
start = hlines(1,2) + 1;
stop = hlines(end,1) - 1;
description = text(start:stop);

end
