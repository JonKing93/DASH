function[rst] = section(section, type, summary, headings, files, h1, links)

% Join the heading blocks
contents = [];
nHeading = numel(headings);
for h = 1:nHeading
    nextblock = format.package.heading(type, headings(h), files{h}, h1{h}, links{h});
    if strlength(nextblock)>0
        contents = strjoin([contents, nextblock], "\n\n");
    end
end

% Title case the section
if strlength(section)>0
    section = lower(section);
    section = char(section);
    newword = [0, regexp(section, ' \w')]+1;
    section(newword) = upper(section(newword));
    
    % Build the underlined title
    underline = repmat('-', 1, strlength(section));
    title = strcat(string(section), "\n", underline, "\n");
    
    % Optionally add a section summary
    if strlength(summary)>0
        title = strcat(title, string(summary), "\n");
    end
    title = strcat(title, "\n");
else
    title = "";
end

% Optionally build a toctree
toctree = "";
if type==3
    toctree = strcat(".. toctree::", '\n', "    :hidden:", "\n\n");
    for h = 1:nHeading
        nFile = numel(files{h});
        for f = 1:nFile
            linked = sprintf("%s <%s>", files{h}(f), links{h}(f));
            toctree = strcat(toctree, sprintf("    %s\n", linked));
        end
    end
    toctree = strcat(toctree, '\n');
end

% Format
rst = strcat(...
    title,          ...  trailing newline
    contents,       ...  trailing newline
    toctree         ...  trailing newline
    );

end