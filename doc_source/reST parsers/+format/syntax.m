function[rst] = syntax(signatureBlocks, links)
%% format.syntax  Format the list of function syntax signature blocks
% ----------
%   rst = format.syntax(signatureBlocks, links)
%   Formats the reST markup for a set of syntax signatures. Links each
%   signature block to the associated usage description.
% ----------
%   Inputs:
%       signatureBlocks (string vector): Blocks of function signatures.
%           Individual signatures are separated by newlines
%       links (string vector): Link to the usage details for each syntax
%
%   Outputs:
%       rst: reST markup for the syntax section

% Get the individual signatures in each block
syntaxText = [];
for s = 1:numel(signatureBlocks)
    signatures = split(signatureBlocks(s), newline);

    % Build the line for each signature
    for k = 1:numel(signatures)
        line = sprintf("| :ref:`%s <%s>`\n", signatures(k), links(s));
        syntaxText = strcat(syntaxText, line);
    end
end

% Format the overall syntax section
rst = strcat(...
    "Syntax",                '\n',...
    '------',                '\n',...
                             '\n',...
    '.. raw:: html\n\n    <pre>\n\n',...
    '.. rst-class:: syntax', '\n',...
                             '\n',...
    syntaxText,                   ... % trailing newline 
                             '\n',...
    '.. raw:: html\n\n    </pre>\n\n',...
    '----',                  '\n',...
    '\n'                          ...
    );

end