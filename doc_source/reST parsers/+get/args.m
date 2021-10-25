function[args] = args(sectionName, header)
%% Get help text for a function argument. (Inputs, Outputs, Saves, Throws, etc.)
% ----------
%   args = get.args(sectionName, header)
% ----------
%   Inputs:
%       sectionName (string scalar): Inputs, Outputs, Saves, Throws, etc.
%       header (char vector): The help text for a function
%
%   Outputs
%       args (char vector): The text detailing the argument

% Move below the usage section
eol = find(header==10);
k = get.lastUsageLine(header, eol);
header = header( eol(k)+1:end );

% Get each line of text
eol = [0, find(header==10)];
nLines = numel(eol);

% Scan through each line of text, checking for the section
eol = [0, find(header==10)];
inSection = false;
start = [];
for k = 2:nLines
    line = header(eol(k-1)+1:eol(k));
    blank = all(isspace(line(2:end)));
    
    % Section header
    if ~inSection && contains(line, strcat("%   ",sectionName))
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
        
        

