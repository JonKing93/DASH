function[text, eol] = belowH1(helpText)
%% get.belowH1  Return help text below the initial (H1) line and its section break
% ----------
%   [text, eol] = get.belowH1(helpText)
%   Returns all help text after the first line and its section break.
%   Checks that there is a correctly formatted section break on line 2.
% ----------
%   Inputs:
%       header (char vector): Help text
%
%   Outputs:
%       text (char vector): The help text below the H1 line.
%       eol (linear indices): The locations of the newline characters in
%           the returned text.

% Require at least 1 newline character
eol = find(helpText==10);
nEOL = numel(eol);
assert(nEOL>1, 'The help text has a single line');

% Check the second line is a section break
line2 = helpText(eol(1)+1 : eol(2)-1);
line2 = strip(line2, 'right');
assert(strcmp(line2, '% ----------'), 'The second line of the help text is not a section break');

% Return everything below the section break
if nEOL == 2
    text = '';
    eol = [];
else
    text = helpText(eol(2)+1:end);
    eol = eol(3:end) - eol(2);
end

end