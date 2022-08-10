function[lines] = lines(limits, text, eol)
%% get.lines  Extract specified lines of text
% ----------
%   lines = get.lines(limits, text, eol)
%   Extracts specified lines of text.
% ----------
%   Inputs:
%       limits (vector [2], positive integers): The starting and stopping
%           line of the text to extract. First element is start line,
%           second element is stop line.
%       text (char vector): The text that contains the desired lines
%       eol (vector, linear indices): The location of the end-of-line
%           characters in the text.
%
%   Outputs:
%       lines (char vector): The text of the requested lines

% Get the start and stop of the requested text
if limits(1)==1
    start = 1;
else
    start = eol(limits(1)-1) + 1;
end
stop = eol(limits(2));

% Extract the lines
lines = text(start:stop);

end