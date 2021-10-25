function[labels, details] = examples(file)
%% Parse example labels and details from examples file
% ----------
%   [labels, details] = parse.examples(file)
% ----------
%   Inputs:
%       file (string scalar): The name of an examples file
%
%   Outputs:
%       labels (string vector): List of examples sections
%       details (string vector): Details for each section

text = fileread(file);
text(text==13) = [];

% Preallocate labels and sections
labels = strings(0,1);
details = strings(0,1);
entry = 0;

% Scan lines
eol = [0, find(text==10)];
nLines = numel(eol);
for k = 2:nLines
    line = text(eol(k-1)+1:eol(k));
    
    % Ended by end of file
    if k==nLines
        details(entry) = text(start:eol(k));
        
    % New section causes end of example
    elseif line(1)=='%' && line(2)=='%'
        if entry ~=0
            details(entry) = text(start:eol(k-1));
        end
        
        % Initialize new example
        line = line(3:end);
        line = strip(line);
        labels = cat(1, labels, line);
        entry = entry+1;
        start = eol(k+1)+1;
    end
end

end