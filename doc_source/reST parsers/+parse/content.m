function[sections, files, summaries] = content(contents)
%% parse.content  Return the sections, files, and file summaries for a package
% ----------
%   [sections, files, summaries] = parse.content(contents)
%   Given the details section of a package's help text, returns the
%   sections used to group the file contents, the files in each section,
%   and the summary of each file.
% ----------
%   Inputs:
%       contents (char vector): The details section of a package's help text
%
%   Outputs:
%       sections (string vector [nSections]): The title of each grouping of
%           contents
%       files (string vector [nSections]): The files in each content
%           section. Individual files are separated by newlines.
%       summaries (string vector [nSections]): The summaries of the files
%           in each section. Individual summaries are separated by newlines

% Require two points
if ~isindented(contents, 2)
    error('rst:parser', 'The content description must be indented by two points');
end

% Initialize the sections
sections = strings(0,1);
files = strings(0,1);
summaries = strings(0,1);
s = 0;

% Get the lines of the content description
eol = find(contents==10);
nLines = numel(eol);

% Scan through the lines of the description
dash1 = [];
newSection = true;
for k = 1:nLines
    line = get.line(k, contents, eol, 3);
    line = char(line);

    % Empty lines trigger a new section
    if isempty(line)
        if newSection
            error('rst:parser', 'Line %.f of the content description cannot be empty', k);
        end
        newSection = true;

    % New section must have a title
    elseif newSection
        newSection = false;
        if isspace(line(3))
            error('rst:parser', 'Line %.f of the content description must begin at character 3', k);
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
    
    % Scan a line. Require correct formatting. Join with newlines
    else
        [file, summary, dash1] = parse.file(line, dash1);
        files(s) = strcat(files(s), string(newline), file);
        summaries(s) = strcat(summaries(s), string(newline), summary);
    end
end

% Remove leading/trailing whitespace
files = strip(files);
summaries = strip(summaries);

end