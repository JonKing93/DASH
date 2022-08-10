function[rst] = introduction(title, h1, sections, sectionContents)
%% format.introduction  Format the RST markup for the introductory description section of a class or package
% ----------
%   rst = format.introduction(title, h1, sections, sectionContents)
%   Formats the introduction to a class or package. Places the H1 summary
%   under the item title. Place descriptions in a "Description" section
%   with nested description sections.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing scalar of the item
%       h1 (string scalar): The H1 summary
%       sections (string vector [nSections]): The titles of each
%           description subsection. The first title should be empty.
%       sectionContents (string vector [nSections]): The contents of each
%           description subsection. Paragraphs are separated by two
%           newlines. Ordered lists are treated as a separate paragraph and
%           list items are separated by single newlines
%
%   Outputs:
%       rst (char vector): reST markup for the introductory description

% Get underline
underline = repmat('=', [1 strlength(title)]);

% Format title and H1
rst = strcat(...
    title,          '\n',...
    underline,      '\n',...
    h1,             '\n',...
                    '\n',...
    '----',         '\n',...
                    '\n'...
    );

% Exit if there is no description
if isempty(sections)
    return
end

% Format the RST for each description section
for s = 2:numel(sectionContents)
    sectionContents(s) = formatSection(sections(s), sectionContents(s));
end
description = strjoin(sectionContents, "\n\n\n");

% Add to the introduction
rst = strcat(...
    rst,                ...
    'Description',  '\n',...
    '-----------',  '\n',...
    description,    '\n',...
                    '\n',...
    '----',         '\n',...
                    '\n'...
    );
end
function[rst] = formatSection(section, content)

% Titlecase the section title
section = lower(section);
section = char(section);
newWord = [0, regexp(section, ' \w')]+1;
section(newWord) = upper(section(newWord));

% Get components
underline = repmat('+', [1, strlength(section)]);

% Format
rst = strcat(...
    section,     '\n',...
    underline,   '\n',...
    content...
    );

end