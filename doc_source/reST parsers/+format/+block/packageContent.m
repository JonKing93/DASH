function[rst] = packageContent(section, files, h1, links)

% Section underline
underline = repmat('-', 1, strlength(section));

% Linked files
nFiles = numel(files);
linked = strings(nFiles, 1);
for f = 1:nFiles
    linked(f) = sprintf("%s <%s>", files(f), links(f));
end

% Section contents
contents = [];
for f = 1:nFiles
    line = sprintf("| :doc:`%s` - %s\n", linked(f), h1(f));
    contents = strcat(contents, line);
end

% toctree
toctree = strcat(...
    ".. toctree::", '\n',...
    "    :hidden:", "\n\n");
for f = 1:nFiles
    toctree = strcat(toctree, sprintf("    %s\n",linked(f)));
end

% Format
rst = strcat(...
    section,                        "\n",...
    underline,                      '\n',...
                                    '\n',...
    '.. rst-class:: package-links', '\n',...
                                    '\n',...
    contents,                            ... trailing newline
                                    '\n',...
    toctree                              ... trailing newline
    );

end
    