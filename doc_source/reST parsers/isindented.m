function[tf] = isindented(text, indent)
%% isindented  Test if text is indented by a certain amount
% ----------
%   tf = isindented(text, indent)
%   True if text is indented by the indicated number of characters.
%   Otherwise false
% ----------
%   Inputs:
%       text (char vector): The text being tested
%       indent (scaalr positive integer): The required amount of indenting
%
%   Outputs:
%       tf (scalar logical): True if every line of the text is indented by
%           the specified amount. Otherwise false

% Initialize test
tf = true;

% Find newlines
eol = find(text==10);
nLines = numel(eol);

% Get each line of text
for k = 1:nLines
    line = get.line(k, text, eol, 0);
    line = char(line);

    % Test for indenting. Exit if any line is not indented
    maxChar = min(indent, numel(line));
    line = line(1:maxChar);
    if ~all(isspace(line))
        tf = false;
        break
    end
end

end
