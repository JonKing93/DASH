function[rst] = examples(labels, details, handles)
%% format.examples  Build the reST markup for the examples section
% ----------
%   rst = format.examples(labels, details, handles)
%   Builds the examples section. Places each example in a collapsed
%   accordion.
% ----------
%   Inputs:
%       labels (string vector): Titles of examples sections
%       details (string vector): .rst markup of the content of each example
%           section
%       handles (string vector): Handle IDs for collapsible sections
%
%   Outputs:
%       rst: The reST markup for the examples section

% Empty case
if isempty(labels)
    rst = '';
    return
end

% Contents blocks
nExamples = numel(labels);
blocks = strings(nExamples, 1);
for k = 1:nExamples
    blocks(k) = formatBlock(labels(k), details(k), handles(k));
end
blocks = join(blocks, "\n\n\n");

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
    
% Utilities
function[rst] = formatBlock(label, content, handle)

% Build components
underline = repmat('+', [1, strlength(label)]);
accordion = format.accordion(label, content, handle, false);

% Format
rst = strcat(...
    ".. rst-class:: collapse-examples", "\n",...
                                        '\n',...
    label,                              '\n',...
    underline,                          '\n',...
                                        '\n',...
    accordion                                ... % trailing newline
    );

end