function[title, summary] = h1(helpText)
%% parse.h1  Extracts function title and summary from the first line of function help text
% ----------
%   [title, summary] = parse.h1(helpText)
%   Extracts function title and summary from the first line of function
%   help text.
% ----------
%   Inputs:
%       helpText (char vector): The help text for a function
%
%   Outputs:
%       title (string scalar): The full dot-indexing title of the function
%       summary (string scalar): The H1 summary of the function

% Get the H1 line, strip trailing whitespace
h1 = get.h1(helpText);
h1 = strip(h1, 'right');

% Check initial formatting
assert(numel(h1)>=3, 'The H1 line is too short');
assert(strcmp(h1(1:2), '% '), 'The H1 line does not begin with "% "');
assert(isletter(h1(3)), 'The H1 title does not begin on element 3');

% Extract non-whitespace blocks. Remove the % sign
h1Strings = string(strsplit(h1));
h1Strings(1) = [];

% Require a title and summary. Require exactly 2 spaces between them
assert(numel(h1Strings)>=2, 'The H1 line is missing a summary');
titleLength = strlength(h1Strings(1));
minLength = 2 + titleLength + 3;
assert(numel(h1)>=minLength, 'The H1 line is too short');
spaces = 2 + titleLength + (1:2);
assert(all(isspace(h1(spaces))), 'The H1 title must be followed by two spaces');
assert(isletter(h1(minLength)), 'The H1 summary must begin three points after the title');

% Title is the first text key, the remaining lines are the summary
title = h1Strings(1);
summary = strjoin(h1Strings(2:end));

end