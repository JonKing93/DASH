function[description] = miscBlock(block, blockName)
%% parse.miscBlock  Parses a description from a miscellaneous description block
% ----------
%   description = parse.miscBlock(block)
%   Returns the description that follows a miscellaneous description block
%   in a function or method help text. Typically, these blocks are
%   "Prints", "Saves", or "Downloads"
% ----------
%   Inputs:
%       block (char vector | ''): The help text for the block. If there is
%           no block, use an empty char array.
%
%   Outputs:
%       description (string scalar | ''): The description for the block

% Empty case
if isempty(block)
    description = '';
    return
end

% Default
if ~exist('blockName','var')
    blockName = 'the information block';
end

% Remove the first (title) line of the block
eol = find(block==10, 1);
block(1:eol) = [];

% Require 8 point indenting. Remove indents from block
assert.indented(block, 8, blockName);
block(1:8) = [];
block = replace(block, sprintf('\n        '), newline);

% Remove any trailing blank lines
block = strip(block, 'right');
block = [block, newline];

% Locate all the newline characters
eol = find(block==10);
nLines = numel(eol);

% Scan through lines of the block
description = "";
newParagraph = true;
for k = 1:nLines
    line = get.line(k, block, eol);

    % Empty triggers new paragraph
    if line == ""
        newParagraph = true;

    % New paragraph is joined via double newline
    elseif newParagraph
        description = join([description, line], [newline newline]);

    % Continuing paragraph is joined with a space
    else
        description = join([description, line], " ");
    end
end
description = strip(description);

end