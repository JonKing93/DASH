function[groups, groupTypes, groupSummaries, groupSections, sectionMethods, methodSummaries] = methods(title, methods)
%% parse.methods  Parse the help text for class methods
% ----------
%   [groups, types, groupSummaries, sections, methods, summaries] = parse.methods(title, methods)
%   Parse the description of methods within a class's help text.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of the class
%       methods (char vector): The methods section of the help text for a class
%
%   Outputs:
%       groups (string vector [nGroups]): The names of the groups of
%           section of methods
%       types (numeric vector [nGroups]): Indicates the type of each group
%           1: **, no sections
%           2: *, sections
%           3: ==, sections
%       groupSummaries (string vector [nGroups]): A single paragraph summary of each group
%       groupSections (string vector [nGroups]): The names of the sections
%           in each group. Sections within a group are separated by
%           newlines
%       sectionMethods (string vector [nGroups]): The names of the methods
%           in each section. Sections within a group are separated by
%           double newlines. Methods within a section are separated by
%           single newlines.
%       methodSummaries (string vector [nGroups]): The H1 summaries for
%           each method. Sections within a group are separated by double
%           newlines. Methods within a section are separated by single
%           newlines.

% Require two point indenting
if ~isindented(methods, 2)
    error('rst:parser', 'The methods section must be indented by two points');
end

% Get the short title
titleParts = split(title, '.');
name = string(titleParts(end));

% Get the lines of the methods description
eol = find(methods==10);
nLines = numel(eol);

% The first line must format the Matlab method tag
line = get.line(1, methods, eol, 3);
methodsTag = sprintf('  %s Methods:', name);
if ~startsWith(line, methodsTag)
    error('rst:parser', 'The first line of the methods description must begin with the methods tag');
elseif numel(line) > numel(methodsTag)
    error('rst:parser', 'There cannot be text after the methods tag');
end

% The second line must be empty
line = get.line(2, methods, eol);
if line ~= ""
    error('rst:parser', 'The second line of the methods description must be blank');
end

% Get the third line and check formatting
line = get.line(3, methods, eol, 3);
line = char(line);
if isempty(line)
    error('rst:parser', 'The third line of the methods cannot be empty');
elseif isspace(line(3))
    error('rst:parser', 'The third line of the methods must have text at the third character');
end

% If line 3 does not begin with a grouping operator, scan as ungrouped contents
if ~startsWith(line, '  *') && ~startsWith(line, '  =')
    methods = get.lines([3 nLines], methods, eol);
    [sections, files, summaries] = parse.content(methods);

    % Organize as a single group with no title or summary
    groups = "";
    groupTypes = 0;
    groupSummaries = "";
    groupSections = sections;
    sectionMethods = join(files, [newline newline]);
    methodSummaries = join(summaries, [newline newline]);
    return
end

% Count the number of groups
group1 = regexp(methods, '\n  \*\*')';
group2 = regexp(methods, '\n  \*[^*]')';
group3 = regexp(methods, '\n  ==')';

% Sort the groups and get the types
groupIndices = [group1;group2;group3];
types = [ones(numel(group1),1); 1+ones(numel(group2),1); 2+ones(numel(group3),1)];
[groupIndices, order] = sort(groupIndices);
groupTypes = types(order);

% Get the line limits associated with each group
nGroups = numel(groupIndices);
groupLines = NaN(nGroups, 1);
for g = 1:nGroups
    groupLines(g) = find(eol>groupIndices(g), 1);
end
groupLimits = [groupLines, [groupLines(2:end)-1;nLines]];

% Preallocate
groups = strings(nGroups, 1);
groupSummaries = strings(nGroups, 1);
groupSections = strings(nGroups, 1);
sectionMethods = strings(nGroups, 1);
methodSummaries = strings(nGroups, 1);

% Iterate through groups. Check that each group is preceded a newline.
for g = 1:nGroups
    lineNumber = groupLines(g);
    line = get.line(lineNumber-1, methods, eol);
    if line~=""
        error('rst:parser', 'The line before group %.f must be empty', g);
    end

    % If not the first group, require 2 newlines
    if lineNumber~=3
        line = get.line(lineNumber-2, methods, eol);
        if line ~= ""
            error('rst:parser', 'Group %.f is not preceded by 2 newlines', g);
        end
    end

    % Get the lines associated with the group
    lines = get.lines(groupLimits(g,:), methods, eol);

    % Group 1 -- ** marker, single list of files with no sections
    if groupTypes(g) == 1
        [groups(g), groupSummaries(g), sectionMethods(g), methodSummaries(g)] = ...
                                                        scanGroup1(lines);

    % Group 2 -- * marker, sections heading with files
    elseif groupTypes(g) == 2
        [groups(g), groupSummaries(g), groupSections(g), sectionMethods(g), ...
            methodSummaries(g)] = scanGroup2(lines);

    % Group 3 -- == marker, sections heading with files
    elseif groupTypes(g) == 3
        [groups(g), groupSummaries(g), groupSections(g), sectionMethods(g), ...
            methodSummaries(g)] = scanGroup3(lines);
    end
end

% Remove excess whitespace
groupSummaries = strip(groupSummaries);
groupSections = string(groupSections);

end

% Utilties
function[groupTitle, groupSummary, files, summaries] = scanGroup1(group)

% Get the new lines
eol = find(group==10);
nLines = numel(eol);

% Check the title line is formatted correctly
line = get.line(1, group, eol);
line = char(line);
if numel(line)<5
    error('The group title must have non-operator text');
elseif ~endsWith(line, '**')
    error('The group title line must end with **');
elseif numel(strfind(line, '*')) ~= 4
    error('The group title line must have exactly 4 * characters');
end

% Get the title
groupTitle = line(3:end-2);

% Initialize the outputs
groupSummary = "";
files = "";
summaries = "";

% Initialize the scanner
inSummary = true;
startGroup = false;
inGroup = false;

% Scan through the lines of the group
dash1 = [];
for k = 2:nLines
    line = get.line(k, group, eol, 3);
    line = char(line);

    % First blank line ends the summary. There should only be a single newline
    % between the summary and contents. A second newline ends the group
    if isempty(line)
        if inSummary
            inSummary = false;
            startGroup = true;
        elseif startGroup
            error('There should only be a single blank line between the group summary and its contents');
        elseif inGroup
            inGroup = false;
        end

    % Summary line
    elseif inSummary
        line = strip(line);
        if isspace(line(1))
            error('Group summary must have text at character 3');
        end
        groupSummary = strcat(groupSummary, " ", line);

    % Parse a line in the group
    else
        [file, summary, dash1] = parse.file(line, dash1);
        files = strcat(files, string(newline), file);
        summaries = strcat(summaries, string(newline), summary);

        % Note position in group
        startGroup = false;
        inGroup = true;
    end
end

% Remove leading/trailing whitespace
files = strip(files);
summaries = strip(summaries);

end
function[groupTitle, groupSummary, sections, files, summaries] = scanGroup2(group)

% Get the new lines
eol = find(group==10);
nLines = numel(eol);

% Check the title line is formatted correctly
line = get.line(1, group, eol);
line = char(line);
if numel(line)<3
    error('The group title must have non-operator text');
elseif ~endsWith(line, '*')
    error('The group title line must end with *');
elseif numel(strfind(line, '*')) ~= 2
    error('The group title line must have exactly 2 * characters');
end

% Get the title
groupTitle = line(2:end-1);

% Initialize the outputs
groupSummary = "";
sections = strings(0,1);
files = strings(0,1);
summaries = strings(0,1);
s = 0;

% Initialize the scanner
inSummary = true;
newSection = false;

% Scan through the lines of the group
dash1 = [];
for k = 2:nLines
    line = get.line(k, group, eol, 3);
    line = char(line);

    % First blank line ends the summary. Subsequent newlines end a section
    if isempty(line)
        newSection = true;
        if inSummary
            inSummary = false;
        end

    % Summary line
    elseif inSummary
        line = strip(line);
        if isspace(line(1))
            error('Group summary must have text at character 3');
        end
        groupSummary = strcat(groupSummary, " ", line);

    % Section title
    elseif newSection
        newSection = false;
        if isspace(line(4))
            error('rst:parser', 'Line %.f of the group must begin at character 4', k);
        elseif ~endsWith(line, ':')
            error('rst:parser', 'Section title "%s" must end with a colon', line);
        elseif startsWith(line, '  *') || startsWith(line, '  =')
            error('rst:parser', 'Section title "%s" cannot start with a * or =', line);
        end

        % Create new section
        s = s+1;
        sections(s) = line(3:end-1);
        files(s) = "";
        summaries(s) = "";

    % Parse a file and summary in the section
    else
        [file, summary, dash1] = parse.file(line, dash1);
        files(s) = strcat(files(s), string(newline), file);
        summaries(s) = strcat(summaries(s), string(newline), summary);
    end
end

% Remove leading/trailing whitespace
files = strip(files);
summaries = strip(summaries);

% Join section items into a single string
sections = join(sections, newline);
files = join(files, [newline newline]);
summaries = join(summaries, [newline newline]);

end
function[groupTitle, groupSummary, sections, files, summaries] = scanGroup3(group)

% Get the new lines
eol = find(group==10);
nLines = numel(eol);

% Check the title line is formatted correctly
line = get.line(1, group, eol);
line = char(line);
if numel(line)<5
    error('The group title must have non-operator text');
elseif ~endsWith(line, '==')
    error('The group title line must end with ==');
elseif numel(strfind(line, '=')) ~= 4
    error('The group title line must have exactly 4 = characters');
end

% Get the title
groupTitle = line(3:end-2);

% Initialize the outputs
groupSummary = "";
sections = strings(0,1);
files = strings(0,1);
summaries = strings(0,1);
s = 0;

% Initialize the scanner
inSummary = true;
newSection = false;

% Scan through the lines of the group
dash1 = [];
for k = 2:nLines
    line = get.line(k, group, eol, 3);
    line = char(line);

    % First blank line ends the summary. Subsequent newlines end a section
    if isempty(line)
        newSection = true;
        if inSummary
            inSummary = false;
        end

    % Summary line
    elseif inSummary
        line = strip(line);
        if isspace(line(1))
            error('Group summary must have text at character 3');
        end
        groupSummary = strcat(groupSummary, " ", line);

    % Section title
    elseif newSection
        newSection = false;
        if isspace(line(5))
            error('rst:parser', 'Line %.f of the group must begin at character 5', k);
        elseif ~endsWith(line, ':')
            error('rst:parser', 'Section title "%s" must end with a colon', line);
        elseif startsWith(line, '  *') || startsWith(line, '  =')
            error('rst:parser', 'Section title "%s" cannot start with a * or =', line);
        end

        % Create new section
        s = s+1;
        sections(s) = line(3:end-1);
        files(s) = "";
        summaries(s) = "";

    % In the group
    else
        [file, summary, dash1] = parse.file(line, dash1);
        files(s) = strcat(files(s), string(newline), file);
        summaries(s) = strcat(summaries(s), string(newline), summary);
    end
end

% Remove leading/trailing whitespace
files = strip(files);
summaries = strip(summaries);

% Join section items into a single string
sections = join(sections, newline);
files = join(files, [newline newline]);
summaries = join(summaries, [newline newline]);

end