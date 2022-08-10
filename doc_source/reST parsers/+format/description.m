function[rst] = description(signatures, descriptions, links)
%% format.usage  Build the reST markup for the section of syntax usage details
% ----------
%   rst = format.description(signatures, descriptions, links)
%   Builds the reST markup for a series of syntax signature blocks and
%   usage details. Provides a unique link to each syntax block.
% ----------
%   Inputs:
%       signature (string vector [nSyntax]): Blocks of signatures for
%           each syntax. Individual signatures are separated by newlines.
%           The input and output arguments in the parameters have been
%           replaced by links to the arguments on the documentation page.
%       descriptions (string vector [nSyntax]): Usage details for each
%           syntax. Individual paragraphs are separated by newlines.
%       links (string vector [nSyntax]): A unique hyperlink for each
%           set of usage details.
%
%   Outputs:
%       rst (char vector): The reST markup for the syntax description section

% Format each syntax block
nSyntax = numel(signatures);
blocks = strings(nSyntax, 1);
for s = 1:nSyntax
    blocks(s) = formatBlock(signatures(s), descriptions(s), links(s));
end
blocks = strjoin(blocks, "\n\n");

% Format the description section
rst = strcat(...
    "Description", '\n',...
    '-----------', '\n',...
                   '\n',...
    blocks,             ...  % trailing newline
                   '\n',...
                   '\n',...
    '----',        '\n',...
    '\n'                ...
    );

end

% Utility block
function[rst] = formatBlock(signatures, description, link)
%% Builds the reST markup for a syntax block in the description section
% ----------
%   rst = formatBlock(signatures, description, link)
% ----------
%   Inputs:
%       signatures (string scalar): A block of signatures associated with
%           the syntax. Individual signatures are separated by newlines.
%       description (string scalar): The usage details for the syntax
%       link (string scalar): A unique hyperlink to the usage details
%
%   Outputs:
%       rst (char vector): reST markup for the syntax description

% Get the sphinx reference link
reflink = sprintf(".. _%s:", link);

% Build the block of signatures
signatures = split(signatures, newline);
signatures = sprintf("| %s\n", signatures);

% Separate each paragraph of the usage details with two newlines
description = split(description, newline);
description = strjoin(description, "\n\n");

% Build the reST markup
rst = strcat(...
    '.. raw:: html\n\n    <pre>\n\n',...                         
    reflink,                 "\n",...
                             '\n',...
    '.. rst-class:: syntax', '\n',...
                             '\n',...
    signatures,              ... trailing newline
                             '\n',...
    '.. raw:: html\n\n    </pre>\n\n',...
    description,             '\n'...
    );

end