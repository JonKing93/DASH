function[block] = block(blockName, details, required)
%% get.block  Extracts an information block from the details section of help text
% ----------
%   block = get.block(blockName, details, required)
%   Searches and extracts an information block from the details section of
%   help text. If the block is required and missing, throws an error. If
%   not required and missing, returns an empty text array.
% ----------
%   Inputs:
%       blockName (string scalar): The name of the information block.
%           Typical names include Inputs, Outputs, Saves, Prints, etc.
%       details (char vector): The details section of help text.
%
%   Outputs:
%       block (char vector): The text for the information block.

% Add a newline preceding the first line
details = [newline, details];

% Search for the block title. It should be on the beginning of a line,
% indented by 4 spaces, and followed by a colon.
pattern = sprintf('\n    %s:', blockName);
blockLocation = strfind(details, pattern);
nBlock = numel(blockLocation);

% The block must occur exactly once or 0 times (if not required)
if nBlock == 0
    if required
        error('rst:parser', 'Could not locate the "%s" information block', blockName);
    else
        block = '';
        return
    end
elseif nBlock > 1
    error('rst:parser', 'There are %.f "%s" blocks, but there should only be 1.', nBlock, blockName);
end

% Determine the starting line of the block
details(1) = [];
blockLocation = blockLocation-1;
eol = find(details==10);
nLines = numel(eol);
startLine = find(eol > blockLocation, 1);

% The remainder of the block title line should be whitespace
titleLine = get.line(startLine, details, eol);
if ~strcmp(titleLine, sprintf('%s:', blockName))
    error('rst:parser', 'There are non-whitespace characters after the "%s" block title', blockName);
end

% Scan through lines of details text. Search for the end of the block
anotherBlock = false;
for k = startLine+1:nLines
    line = get.line(k, details, eol, 0);
    line = char(line);

    % End the block if another line has text at character 5.
    if numel(line)>=5 && ~isspace(line(5))
        anotherBlock = true;
        break
    end
end

% Get the ending line of the block. If another block was encountered,
% require a blank line between the two blocks
stopLine = k;
if anotherBlock
    stopLine = stopLine - 1;
    blank = get.line(stopLine, details, eol);
    if blank ~= ""
        error('rst:parser', 'There is not a blank line between the "%s" block and the next information block.', blockName);
    end
end

% Require the block to have at least one line beyond the title
if stopLine == startLine
    error('rst:parser', 'The "%s" block has no information', blockName);
end

% Extract the text for the lines
block = get.lines([startLine stopLine], details, eol);

end
