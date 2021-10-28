function[paragraphs] = paragraphs(text)
%% Parses paragraphs in a description block

% Initialize
paragraphs = strings(0,1);
p = 0;
new = true;

% Get each line of text
eol = [0, find(text==10)];
for k = 2:numel(eol)
    line = text(eol(k-1)+1:eol(k));
    [line, hastext] = parse.line(line);
    
    % New paragraph
    if hastext && new
        paragraphs = cat(1, paragraphs, line);
        p = p + 1;
        new = false;
    
    % Continuing paragraph
    elseif hastext
        paragraphs(p) = strcat(paragraphs(p), " ", line);
    
    % Whitespace triggers new paragraph
    else
        new = true;
    end 
end

end