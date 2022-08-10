function[rst] = content(contentSections, linkedSectionFiles, fileSummaries)
%% format.content  Format the contents section of a package's documentation
% ----------
%   rst = format.contents(sections, linkedFiles, fileSummaries)
%   Formats the reST markup for the contents of a package. Files in the
%   contents are linked to their documentation pages.
% ----------
%   Inputs:
%       sections (string vector [nSections]): The section titles of the contents
%       linkedFiles (string vector [nSections]): The reference links to the
%           files in each section. Individual files within a section are
%           separated by newlines
%       fileSummaries (string vector [nSections]): The H1 summary for each
%           file in each section. Summaries within a section are separated
%           by newlines
%
%   Outputs:
%       rst (char vector): The reST markup for the package contents

% Preallocate
nSections = numel(contentSections);
sections = strings(nSections, 1);

% Format each section. Join sections with triple newlines
for s = 1:nSections
    sections(s) = formatSection(contentSections(s), linkedSectionFiles(s), fileSummaries(s));
end
rst = join(sections, [newline newline newline]);

end

% Utilities
function[rst] = formatSection(title, linkedFiles, summaries)

% Split apart the linked files and their summaries
linkedFiles = split(linkedFiles, newline);
summaries = split(summaries, newline);

% Preallocate the file contents and the toctree lines
nFiles = numel(linkedFiles);
contents = strings(nFiles, 1);
toctree = strings(nFiles, 1);

% Build the file contents and toctree
for f = 1:nFiles
    contents(f) = sprintf("| :doc:`%s` - %s", linkedFiles(f), summaries(f));
    toctree(f) = sprintf("    %s", linkedFiles(f));
end
contents = join(contents, newline);
toctree = join(toctree, newline);

% Title case the section title
title = lower(title);
title = char(title);
newWord = [0, regexp(title, ' \w')]+1;
title(newWord) = upper(title(newWord));

% Get the underline
underline = repmat('-', [1, strlength(title)]);

% Format
rst = strcat(...  
    title,                             '\n',...
    underline,                         '\n',...
                                       '\n',...
    '.. rst-class:: package-links',    '\n',...
                                       '\n',...
    contents,                          '\n',...
                                       '\n',...
    '.. toctree::',                    '\n',...
    '    :hidden:',                    '\n',...
                                       '\n',...
    toctree,                           '\n'...
    );

end