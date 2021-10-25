function[rst] = description(links, signatures, details)
%% reST markup for the function description section
% ----------
%   rst = format.description(links, signatures, details)
% ----------
%   Inputs:
%       links (string vector): Link to each syntax
%       signatures (string vector): Set of syntaxes / function signatures
%       details (cell vector): Usage details for each syntax. Elements are
%           paragraphs of the description.
%
%   Outputs:
%       rst: The markup for the description section

% Format each block
blocks = [];
for s = 1:numel(signatures)
    nextblock = format.block.description(links(s), signatures(s), details{s});
    blocks = strcat(blocks, nextblock);
end

% Format the description section
rst = strcat(...
    "Description", '\n',...
    '-----------', '\n',...
                   '\n',...
    blocks             ,...
                        ...   % trailing newlines
    '----',        '\n',...
                   '\n'...
    );

end            