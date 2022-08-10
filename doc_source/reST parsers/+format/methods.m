function[rst] = methods(groups, types, groupSummaries, sections, files, summaries, inheritance)
%% format.methods  Builds the RST markup for the methods section of a class help section
% ----------
%   rst = format.methods(groups, types, groupSummaries, sections, files, summaries)
%   Builds the RST markup for the methods section of a class.
% ----------
%   Inputs:
%       groups (string vector [nGroups]): The names of the major groups
%           within the methods section. These are typically "Key Methods",
%           "User Methods", and "Utilities". If there is no group title,
%           groups will consist of a scalar empty string "".
%       types (numeric vector [nGroups]): Indicates the type of each group.
%           0: There is no group title. Methods are split into sections
%           1: ** group title. No sections
%           2: * group title. Has sections
%           3: == group title. Has sections
%       groupSummaries (string vector [nGroups]): A summary of each group.
%           If there are no groups, consists of a scalar empty string
%       sections (string vector [nGroups]): The section titles that occur
%           within each group. Individual sections are separated by newlines
%       files (string vector [nGroups]): The file reference links within each section.
%           Sections in a group are separated by double newlines. Files
%           within a section are separated by single newlines.
%       summaries (string vector [nGroups]): The H1 summary of each file in
%           a section. Double newlines between sections, single newlines
%           between files within a section.
%
%   Outputs:
%       rst (char vector): The formatted reST for the methods section

% Build each group, join with triple newlines and a line break
nGroups = numel(groups);
groupRST = strings(nGroups, 1);
for g = 1:nGroups
    if types(g) == 0
        groupRST(g) = formatGroup23("Methods", "", sections, files, summaries, inheritance);
    elseif types(g) == 1
        groupRST(g) = formatGroup1(groups(g), groupSummaries(g), files(g), summaries(g));
    else
        groupRST(g) = formatGroup23(groups(g), groupSummaries(g), sections(g), ...
                                   files(g), summaries(g), inheritance(g));
    end
end
rst = join(groupRST, [newline newline, '----', newline, newline]);

end

% Utilities
function[rst] = formatGroup1(title, groupSummary, files, summaries)

% Split the files and summaries
files = split(files, newline);
summaries = split(summaries, newline);

% Preallocate
nFiles = numel(files);
contents = strings(nFiles, 1);

% Build the file contents
for f = 1:nFiles
    contents(f) = sprintf("| :doc:`%s` - %s", files(f), summaries(f));
end
contents = join(contents, newline);

% Title case the group title
title = lower(title);
title = char(title);
newWord = [0, regexp(title, ' \w')]+1;
title(newWord) = upper(title(newWord));

% Build components
newlin = string(newline);
underline = repmat('-', [1 strlength(title)]);

% Format
rst = strcat(...
    title,                           newlin,...
    underline,                       newlin,...
    groupSummary,                    newlin,...
                                     newlin,...
    '.. rst-class:: package-links',  newlin,...
                                     newlin,...
    contents,                        newlin...
    );

end
function[rst] = formatGroup23(title, groupSummary, sections, files, summaries, inheritance)

% Split apart the sections
sections = split(sections, newline);
files = split(files, [newline newline]);
summaries = split(summaries, [newline newline]);
inheritance = split(inheritance, newline);

% Preallocate
nSections = numel(sections);
sectionRST = strings(nSections, 1);

% Format each section. Join sections with triple newlines
for s = 1:nSections
    sectionRST(s) = formatSection(sections(s), files(s), summaries(s), inheritance(s));
end
contents = join(sectionRST, [newline newline]);

% Title case the group title
title = lower(title);
title = char(title);
newWord = [0, regexp(title, ' \w')]+1;
title(newWord) = upper(title(newWord));

% Build components
newlin = string(newline);
underline = repmat('-', [1 strlength(title)]);

% Format
rst = strcat(...
    title,                           newlin,...
    underline,                       newlin,...
    groupSummary,                    newlin,...
                                     newlin,...
    contents,                        newlin...
    );

end
function[rst] = formatSection(title, linkedFiles, summaries, inheritance)

% Split apart the linked files and their summaries
linkedFiles = split(linkedFiles, newline);
summaries = split(summaries, newline);
inherited = char(inheritance) == '1';

% Preallocate the file contents and the toctree lines
nFiles = numel(linkedFiles);
contents = strings(nFiles, 1);
toctree = strings(nFiles, 1);

% Add files to toctree if not inherited
for f = 1:nFiles
    if ~inherited(f)
        toctree(f) = sprintf("    %s", linkedFiles(f));
    end

    % Build the file contents
    contents(f) = sprintf("| :doc:`%s` - %s", linkedFiles(f), summaries(f));
end
contents = join(contents, newline);

% Build toctree from non-empty elements
remove = strcmp(toctree, "");
toctree(remove) = [];
if ~isempty(toctree)
    toctree = join(toctree, newline);
    toctree = strcat(...
        ".. toctree::",    '\n',...
        '    :hidden:',    '\n',...
                           '\n',...
        toctree,           '\n'...
        );
else
    toctree = '';
end

% Title case the section title
title = lower(title);
title = char(title);
newWord = [0, regexp(title, ' \w')]+1;
title(newWord) = upper(title(newWord));

% Get the underline
underline = repmat('+', [1, strlength(title)]);

% Format
rst = strcat(...  
    title,                             '\n',...
    underline,                         '\n',...
                                       '\n',...
    '.. rst-class:: package-links',    '\n',...
                                       '\n',...
    contents,                          '\n',...
                                       '\n',...
    toctree                 ... trailing newline
    );

end
