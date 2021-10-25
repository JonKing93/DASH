function[sections, files, h1] = packageContents(help)
%
% sections (string vector): Named sections
% files (cell vector): Files in each section
% h1 (cell vector): H1 line for each file

% Move below the description
eol = find(help==10);
k = get.lastUsageLine(help, eol);
contents = help(eol(k)+1:end);

% Preallocate
sections = strings(0,1);
files = cell(0,1);
h1 = cell(0,1);
s = 0;

% Get each line of text
eol = [0, find(contents==10)];
for k = 2:numel(eol)
    line = contents(eol(k-1)+1:eol(k));
    
    % Ignore blank lines and doc links
    if all(isspace(line(2:end))) || contains(line, '<a href=')
        continue;
    end
    
    % Remove comment symbol, strip newlines
    line = line(3:end);
    line = strip(line, 'right');
    
    % New section
    if ~isspace(line(1))
        sections = cat(1, sections, line(1:end-1));
        files = cat(1, files, {strings(0,1)});
        h1 = cat(1, h1, {strings(0,1)});
        s = s+1;
        
    % File in a section
    else
        line = strip(line, 'left');
        firstSpace = find(line==' ', 1);
        files{s} = cat(1, files{s}, line(1:firstSpace-1));
        firstHyphen = find(line=='-', 1);
        h1{s} = cat(1, h1{s}, line(firstHyphen+2:end));
    end
end

end