function[paragraphs] = paragraphs(text)
%% Parses paragraphs in a description block

% Initialize
paragraphs = strings(0,1);
p = 0;
new = true;
inlist = false;

% Get each line of text
eol = [0, find(text==10)];
for k = 2:numel(eol)
    line = text(eol(k-1)+1:eol(k));
    [line, hastext] = parse.line(line);
    
    % Restore newline for numbered list
    match = regexp(line, '\d*[.]');
    if ~isempty(match) && match(1)==1
        line = strcat(line, "\n");
        if ~inlist
            line = strcat("\n", line);
            inlist = true;
        end
    else
        inlist = false;
    end
    
    % New paragraph
    if hastext && new
        paragraphs = cat(1, paragraphs, line);
        p = p + 1;
        new = false;
    
    % Continuing paragraph gets a space
    elseif hastext && ~inlist
        paragraphs(p) = strcat(paragraphs(p), " ", line);
        
    % Continuing list has no space
    elseif hastext && inlist
        paragraphs(p) = strcat(paragraphs(p), line);
    
    % Whitespace triggers new paragraph
    else
        new = true;
    end 
end

end