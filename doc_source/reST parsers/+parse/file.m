function[file, summary, dash1] = file(line, dash1)
%% parse.file  Parses the name and H1 summary of a content item from a list
% ----------
%   [file, summary, dash1] = parse.file(line, dash1)
%   Parses a line a text that lists a content file item and its H1 summary.
%   Checks formatting and ensures that hyphens are aligned.
% ----------
%   Inputs:
%       line (char vector): A line of text listing a content item and its
%           H1 summary. The line should retain all left side indenting
%       dash1 (scalar positive integer | []): The required location of the
%           hyphen before the H1 summary. Use an empty array to allow any
%           location
%
%   Outputs:
%       file (string scalar): The name of the file
%       summary (string scalar): The H1 summary for the file
%       dash1 (scalar positive integer): The location of the hyphen before
%           the H1 summary

% Check for correct indenting
if ~all(isspace(line(1:4)))
    error('rst:parser', 'Line\n\t%s\n must be indented by 4 spaces', line);
elseif isspace(line(5))
    error('rst:parser', 'Line\n\t%s\n must begin on character 5', line);
end

% Remove the indent
line = line(5:end);

% Locate the end of the file name
spaces = strfind(line, ' ');
if isempty(spaces)
    error('rst:parser', 'Line\n\t%s\n must have spaces', line);
end
space1 = spaces(1);

% Locate the hyphen before the summary
dashes = strfind(line, '-');
if isempty(dashes)
    error('rst:parser', 'Line\n\t%s\n must have a dash', line);
elseif dashes(1) < space1
    error('rst:parser', 'Line\n\t%s\n must have a space before the hyphen', line);
end

% Require aligned dashes
if isempty(dash1)
    dash1 = dashes(1);
elseif dashes(1)~=dash1
    error('rst:parser', 'The hyphens on line\n\t%s\n are not aligned', line);
end

% Require correct formatting
if ~all(isspace(line(space1:dash1-1)))
    error('rst:parser', 'Line\n\t%s\n has text between the content name and summary', line);
elseif ~isspace(line(dash1+1))
    error('rst:parser', 'Line\n\t%s\n must have a space after the dash', line);
elseif isspace(line(dash1+2))
    error('rst:parser', 'The summary on line\n\t%s\n must begin one space after the dash', line);
end

% Get the file name and summary
file = line(1:space1-1);
summary = line(dash1+2:end);

end