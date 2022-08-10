function[] = indented(text, indent, textName)
%% assert.indented  Throw error if text is not indented by a specific amount
% ----------
%   assert.indented(text, indent)
%   Throw error if text is not indented by a minimum amount of whitespace.
%
%   assert.indented(text, indent, textName)
%   Customize the name of the text in thrown error messages.
% ----------
%   Inputs:
%       text (char vector): The text being checked
%       indent (scalar positive integer): The required amount of whitespace indenting
%       textName (string scalar): Name for the text in thrown error messages

% Default
if ~exist('textName', 'var')
    textName = 'the text';
end

% Get the end-of-line characters
eol = find(text==10);
nLines = numel(eol);

% Get each line of the text
for k = 1:nLines
    line = get.line(k, text, eol, 0);
    line = char(line);

    % Extract the characters in the indent
    maxChar = min(indent, numel(line));
    line = line(1:maxChar);

    % Throw error if any of the indent characters are non-whitespace
    if ~all(isspace(line))
        bad = find(~isspace(line), 1);
        error('rst:parser', ['Line %.f of %s must be indented by %.f characters. However, ',...
            'the line has non-whitespace characters at element %.f.'],...
            k, textName, k, bad);
    end
end

end