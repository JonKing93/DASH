function[description] = description(helpText)
%% get.description  Get the description section of help text
% ----------
%   description = get.description(helpText, required)
%   Extracts the description section from help text. The second line of
%   help text should consist of 10 -s. The description is the text
%   following this line and terminates with another 10 -s.
% ----------
%   Inputs:
%       header (char vector): Help text for an item
%       required
%
%   Outputs:
%       description (char vector): The text of the description section

% Get the text below the H1 line and its section break
[text, eol] = get.belowH1(helpText);

% Search for section breaks
breaks = strfind(text, [newline,'% ----------']);
if numel(text)>=12 && strcmp(text(1:12), '% ----------')
    breaks = [1, breaks];
end
nBreaks = numel(breaks);

% Empty or invalid descriptions
if nBreaks > 1
    error('The help text has more than 2 section breaks');
elseif nBreaks == 0 || breaks==1
    description = '';

% Extract description
else
    lastEOL = eol==breaks;
    endDescription = eol(lastEOL) - 1;
    description = text(1:endDescription);
end

end