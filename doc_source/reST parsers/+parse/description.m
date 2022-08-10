function[sections, sectionContents] = description(description)
%% parse.description  Parses the description of a package or class
% ----------
%   [sections, sectionContents] = parse.description(description)
%   Parses the description section of the help text for a class or package.
%   Section titles are denoted by a blank line followed by a line that ends
%   with a colon. The contents of the section are the subsequent lines.
%   Paragrahs in a section's contents are separated by two newlines.
%   Numeric or alphabetical lists are treated as separate paragraphs. The
%   individual lines of the list are separated by single newlines. 
% ----------
%   Inputs:
%       description (char vector): The description help text for a class or package
%
%   Outputs:
%       sections (string vector [nSections]): The titles of each
%           description subsection. The first title should be empty.
%       sectionContents (string vector [nSections]): The contents of each
%           description subsection. Paragraphs are separated by two
%           newlines. Ordered lists are treated as a separate paragraph and
%           list items are separated by single newlines

% Empty case
if isempty(description)
    sections = strings(0,1);
    sectionContents = strings(0,1);
    return
end

% Initialize the sections and contents
sections = strings(1,1);
sectionContents = strings(1,1);
s = 1;

% Get the lines of the description
eol = find(description==10);
nLines = numel(eol);

% Get the first line. Require it to have text
line = get.line(1, description, eol);
if line == ""
    error('rst:parser', 'The first line of the description cannot be empty');
elseif endsWith(line, ':')
    error('rst:parser', 'The first line of the description cannot be a section title');
end

% Initialize scanner
newParagraph = false;
inList = false;

% Scan through the lines of the description
for k = 1:nLines
    line = get.line(k, description, eol);
    line = char(line);

    % Empty lines end lists and trigger new paragraphs
    if isempty(line)
        newParagraph = true;
        sectionContents(s) = strcat(sectionContents(s), sprintf("\n\n"));
        inList = false;

    % New section
    elseif newParagraph && endsWith(line, ':')
        s = s+1;
        sections(s) = line(1:end-1);
        sectionContents(s) = "";

    % Scanning contents. Check if this line is a list bullet
    else
        listLine = false;
        isNumberList = ~isempty(regexp(line,   '^\d+\.', 'once'));
        isLetterList = ~isempty(regexp(line, '^[A-Z]\.', 'once'));
        if isNumberList || isLetterList
            listLine = true;
        end

        % Initialize delimiter
        delimiter = "";

        % New list. Trigger new paragraph. Set list marker
        if listLine && ~inList
            inList = true;
            if ~newParagraph
                delimiter = [newline newline];
            end
            newParagraph = false;

        % Continuing list - Separate items with newlines. New paragraph -
        % add line directly. Continue line - add a space between words
        elseif listLine
            delimiter = newline;
        elseif newParagraph
            newParagraph = false;
        else
            delimiter = " ";
        end

        % Add the line to the contents. Remove leading/trailing whitespace
        sectionContents(s) = join([sectionContents(s), line], delimiter);
    end
end
sectionContents = strip(sectionContents);

end