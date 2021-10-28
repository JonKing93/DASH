function[rst] = heading(heading, files, h1, links, inherited)

% Heading
if strlength(heading)==0
    htmlHeading = "";
else
    htmlHeading = strcat(...
        ".. raw:: html\n\n    <h3>", string(heading), "</h3>\n\n");
end

% File content
nFiles = numel(files);
if nFiles==0
    contents = "";
else
    
    % Link files, add to contents
    contents = [];
    toctree = [];
    for f = 1:nFiles
        linked = sprintf("%s <%s>", files(f), links(f));
        line = sprintf("| :doc:`%s` - %s\n", linked, h1(f));
        contents = strcat(contents, line);
        
        % Add to toctree if not inherited
        if ~inherited(f)
            toctree = strcat(toctree, sprintf("    %s\n", linked));
        end
    end
    
    % Add toc tree header if tree has elements
    if ~isempty(toctree)
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