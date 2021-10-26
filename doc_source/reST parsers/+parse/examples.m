function[labels, details] = examples(file)

% Read file, remove carriage returns
text = fileread(file);
text(text==13) = [];

% Labels and sections
labels = strings(0,1);
details = strings(0,1);
entry = 0;

% Track code blocks
inBlock = false;

% Scan lines
eol = [0, find(text==10)];
nLines = numel(eol);
for k = 2:nLines
    line = text(eol(k-1)+1:eol(k));
    
    % New section
    if line(1)=='#'
        line = line(3:end);
        line = strip(line);
        labels = cat(1, labels, line);
        entry = entry+1;
        details(entry) = "";
        
    % New code block
    elseif length(line)>=3 && strcmp(line(1:3), '```')        
        if ~inBlock
            inBlock = true;

            % Add html classes for tags
            addline = "";
            tag = strip(line(4:end));
            if strcmp(tag, 'in')
                addline = ".. rst-class:: no-margin\n\n";
            elseif strcmp(tag, 'out')
                addline = ".. rst-class:: example-output\n\n";
            elseif strcmp(tag, 'error')
                addline = ".. rst-class:: example-output error-message \n\n";
            end
            details(entry) = strcat(details(entry), addline);
            
            % Add code marker
            details(entry) = strcat(details(entry), "::\n\n");
            
        % Ended code block
        else
            inBlock = false;
            details(entry) = strcat(details(entry), "\n");
        end
        
    % Continued code block - indent 4 spaces
    elseif inBlock
        details(entry) = strcat(details(entry), "    ", string(line));
        
    % Continued a normal line
    else
        details(entry) = strcat(details(entry), string(line));
    end
end

end