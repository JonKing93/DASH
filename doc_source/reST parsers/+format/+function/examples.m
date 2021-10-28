function[rst] = examples(labels, details, handles)
%% reST markup for the examples section
% ----------
%   rst = format.examples(labels, details, handles)
% ----------
%   Inputs:
%       labels (string vector): Titles of examples sections
%       details (string vector): .rst markup of the content of each example
%           section
%       handles (string vector): Handle IDs for collapsible sections
%
%   Outputs:
%       rst: The reST markup for the examples section

% Contents blocks
blocks = [];
for s = 1:numel(labels)
    nextblock = format.block.example(labels(s), details(s), handles(s));
    blocks = strjoin([blocks, nextblock], "\n\n\n");
end

% Format the section
rst = strcat(...
    "Examples", "\n",...
    "--------", "\n",...
                '\n',...
    blocks,          ... trailing newline
                '\n',...
                '\n',...
    '----',     '\n',...
                '\n'...
    );

end
    