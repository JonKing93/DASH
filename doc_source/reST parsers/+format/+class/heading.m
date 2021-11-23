function[rst] = heading(type, heading, files, h1, links, inherited)

% Heading
if strlength(heading)==0
    htmlHeading = "";
elseif type==2
    headingLength = strlength(heading);
    underline = repmat('+', 1, headingLength);
    htmlHeading = strcat(heading,'\n',underline,'\n\n');
else
    htmlHeading = strcat(...
        ".. raw:: html\n\n    <h3>", string(heading), "</h3>\n\n");
end

% File content
nFiles = numel(files);
if nFiles==0
    contents = "";
else
    
    % Build content section
    contents = [];
    for f = 1:nFiles
        linked = sprintf("%s <%s>", files(f), links(f));
        line = sprintf("| :doc:`%s` - %s\n", linked, h1(f));
        contents = strcat(contents, line);
    end
    
    % Optionally build toctree
    toctree = "";
    if type==2
        for f = 1:nFiles
            if ~inherited(f)
                linked = sprintf("%s <%s>", files(f), links(f));
                toctree = strcat(toctree, sprintf("    %s\n", linked));
            end
        end
    end
    
    % Add toc tree header if tree has elements
    if strlength(toctree)>0
        toctree = strcat(".. toctree::\n    :hidden:\n\n", toctree);
    end
    
    % Final formatting
    contents = strcat(...
        ".. rst-class:: package-links", '\n',...
                                        '\n',...
        contents                            ,...
                                        '\n',...
        toctree                             ...
        );
end

% Combine content and heading
rst = strcat(htmlHeading, contents);

end