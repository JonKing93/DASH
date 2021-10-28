function[rst] = section(section, summary, headings, files, h1, links)

% Join the heading blocks
contents = [];
for h = 1:numel(headings)
    nextblock = format.block.heading(headings(h), files{h}, h1{h}, links{h});
    if strlength(nextblock)>0
        contents = strjoin([contents, nextblock], "\n\n");
    end
end

% Get the section title
if strlength(section)>0
    underline = repmat('-', 1, strlength(section));
    title = strcat(string(section), "\n", underline, "\n");
    if strlength(summary)>0
        title = strcat(title, string(summary), "\n");
    end
    title = strcat(title, "\n");
else
    title = "";
end

% Format
rst = strcat(...
    title,          ...  trailing newline
    contents        ...  trailing newline
    );

end