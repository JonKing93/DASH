function[line] = line(lineNumber, text, eol, stripType)
%% get.line  Extract a specific line from text
% ----------
%   line = get.line(lineNumber, text)
%   Extracts the specified line from a set of text.
%
%   line = get.line(lineNumber, text, eol)
%   Extracts the specified line given a pre-determined set of end-of-line
%   locations.
%
%   line = get.line(lineNumber, text, eol, stripType)
%   line = get.line(lineNumber, text, eol, 0|1|2|3)
%   Indicate how to strip whitespace from the line. If 0, does not strip 
%   whitespace. If 1, strips from both sides. If 2, strips the left side
%   only. If 3, strips the right side only. Default is to strip from both
%   sides (type 1).
% ----------
%   Inputs:
%       lineNumber (scalar positive integer): The index of a line in the text
%       text (char vector): The text containing the line
%       eol (vector, linear indices): The locations of end-of-line
%           characters in the text
%       stripType (numeric integer): Indicates how to strip whitespace
%           [0]: No strip
%           [1 (Default)]: Strip from both sides (leading and trailing)
%           [2]: Strip from the left side only (leading)
%           [3]: Strip from the right side only (trailing)
%
%   Outputs:
%       line (string scalar): The requested line

% Defaults
if ~exist('eol','var') || isempty(eol)
    eol = find(text==10);
end
if ~exist('stripType', 'var') || isempty(stripType)
    stripType = 1;
end

% Get the start and stop character for each line
if lineNumber==1
    start = 1;
else
    start = eol(lineNumber-1) + 1;
end
stop = eol(lineNumber);

% Extract the line and convert to string
line = text(start:stop);
line = string(line);

% Strip whitespace as requested
stripSide = ["both","left","right"];
if stripType ~= 0
    side = stripSide(stripType);
    line = strip(line, side);
end

end
