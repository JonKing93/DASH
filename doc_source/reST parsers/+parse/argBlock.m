function[names, types, details] = argBlock(block, blockName)
%% parse.argBlock  Parses out argument names, types, and descriptions from an Input or Output block
% ----------
%   [names, types, details] = parse.argBlock(block)
%   Parses arguments from the text of an Input or Output block
%
%   ... = parse.argBlock(block, blockName)
%   Customize the name of the argument block in thrown error messages.
% ----------
%   Inputs:
%       block (char vector): The text from an argument block
%       blockName (string scalar): Name of the block for error messages
%
%   Outputs:
%       names (string vector [nArgs]): The names of the arguments described
%           in the block
%       types (string vector [nArgs]): The type description of each argument
%       details (string vector [nArgs]): The description of each argument.
%           Paragraphs are separated by newline characters.

% Empty case
if isempty(block)
    names = strings(0,1);
    types = strings(0,1);
    details = strings(0,1);
    return
end

% Default
if ~exist('blockName','var')
    blockName = 'the information block';
end

% Remove the first (title) line of the block
eol = find(block==10, 1);
block(1:eol) = [];

% Require 8 point indenting. Remove indents from block.
assert.indented(block, 8, blockName);
block(1:8) = [];
block = replace(block, sprintf('\n        '), newline);

% Remove any trailing blank lines
block = strip(block, 'right');
block = [block, newline];

% Locate all the newline characters
eol = find(block==10);
nLines = numel(eol);

% Locate all lines that start a new parameter
startLines = false(nLines, 1);
for lineNumber = 1:nLines
    line = get.line(lineNumber, block, eol, 0);
    line = char(line);
    if ~isspace(line(1))
        startLines(lineNumber) = true;
    end
end

% The first line must start a new parameter
if startLines(1)~=1
    error('rst:parser', 'The first line of %s must list a new parameter. (The parameter must begin at the 9th character).', blockName);
end

% Get the limits of each parameter
lineLimits = find(startLines);
lineLimits = [lineLimits, [lineLimits(2:end)-1;nLines]];

% Preallocate
nParameters = size(lineLimits, 1);
names = strings(nParameters, 1);
types = strings(nParameters, 1);
details = strings(nParameters, 1);

% Iterate through parameters. Extract the first line of the parameter
for p = 1:nParameters
    lineNumber = lineLimits(p,1);
    line = get.line(lineNumber, block, eol);
    line = char(line);

    % Get the parameter name
    space1 = find(line==' ', 1);
    if isempty(space1)
        error('rst:parser', 'The parameter on line %.f of %s is not followed by a space.', lineNumber, blockName);
    end
    names(p) = line(1:space1-1);

    % Require a correctly formatted type declaration on the first line
    errorName = sprintf('the "%s" parameter in %s', names(p), blockName);
    colon1 = find(line==':', 1);
    if isempty(colon1)
        error('rst:parser', '%s does not have a colon on the first line of its description', errorName);
    elseif colon1 < space1 + 4
        error('rst:parser', 'The colon for %s must be at least 4 characters after the space following the parameter name', errorName);
    elseif line(space1+1) ~= '('
        error('rst:parser', '%s does not have a left parenthesis following the space after its name', errorName);
    elseif line(colon1-1) ~= ')'
        error('rst:parser', 'The colon for %s is not immediately preceded by a right parenthesis', errorName);
    end

    % Get the type declaration. Do not allow an empty type
    types(p) = line(space1+2:colon1-2);
    types(p) = strip(types(p));
    if types(p) == ""
        error('rst:parser', 'The type declaration for %s is empty', errorName);
    end

    % Begin the details section
    details(p) = line(colon1+1:end);

    % If the details span multiple lines, get the remaining lines.
    if lineLimits(p,2) > lineLimits(p,1)
        start = lineLimits(p,1) + 1;
        stop = lineLimits(p,2);
        description = get.lines([start stop], block, eol);

        % Build the details from the remainder of the description
        details(p) = buildDetails(description, details(p), errorName);
    end

    % Remove excess whitespace. Don't allow empty details
    details(p) = strip(details(p));
    if details(p) == ""
        error('rst:parser', 'You must provide a description of %s', errorName);
    end
end

end


function[details] = buildDetails(description, details, errorName)

% Require 4 point indenting. Then remove indents
if ~isindented(description, 4)
    error('rst:parser', 'The description of %s is not indented 4 points after the parameter name', errorName);
end
description = [newline, description];
description = replace(description, [newline,'    '], newline);
description(1) = [];

% Get the lines of the description
eol = find(description==10);
nLines = numel(eol);

% Iterate through lines
newParagraph = false;
inNest = false;
for k = 1:nLines
    line = get.line(k, description, eol, 3);
    line = char(line);

    % The first line cannot be empty
    if k==1 && ( isempty(line) || isspace(line(1)) )
        error('rst:parser', 'The second line of the description of %s must have text on the 13th character', errorName);
    end

    % Empty line initiates new paragraph
    if isempty(line)
        newParagraph = true;

    % Brackets and periods trigger a new paragraph and nested description
    elseif line(1)=='[' || line(1)=='.'
        details = join([details, line], newline);
        newParagraph = false;
        inNest = true;

    % New paragraph
    elseif newParagraph
        details = join([details, line], newline);
        newParagraph = false;

    % Nested description
    elseif inNest
        if ~isindented(line, 4)
            error('Line\n\t%s\nis not indented 4 characters', line);
        end
        line = strip(line, 'left');
        details = join([details, line], " ");

    % Continuing paragraph is joined via a space
    else
        details = join([details, line], " ");
    end
end

end

