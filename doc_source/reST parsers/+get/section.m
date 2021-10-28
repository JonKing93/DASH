function[args] = section(name, header)
%% Get help text for a section of the details
% ----------
%   args = get.args(name, header)
% ----------
%   Inputs:
%       name (string scalar): Inputs, Outputs, Saves, Throws, etc.
%       header (char vector): The help text for a function
%
%   Outputs
%       args (char vector): The text detailing the argument

% Get the details section
[header, eol] = get.details(header);

% Get the lines of text
eol = [0, eol];
nLines = numel(eol);

% Scan through each line of text, checking for the section
inSection = false;
start = [];
for k = 2:nLines
    line = header(eol(k-1)+1:eol(k));
    
    % Section header
    if ~inSection && contains(line, strcat("%   ",name))
        start = eol(k-1)+1;
        inSection = true;
        
    % Section ended with blank line
    elseif inSection && all(isspace(line(2:end)))
        stop = eol(k-1);
        break;
        
    % Section ended with end of header
    elseif inSection && k==nLines
        stop = eol(k);
        break;
    end
end

% Restrict to arg section
if isempty(start)
    args = '';
else
    args = header(start:stop);
end

end
        
        

