function[rst] = description(link, signatures, details)
%% reST formatting for function syntax usage details
% ----------
%   rst = format.block.description(link, signature, details)
% ----------
%   Inputs:
%       link (string scalar): Reference link to the syntax description
%       signature (string scalar): The function signature
%       details (string scalar): reST formatted usage details
%
%   Outputs:
%       rst: reST markup for the syntax description

reflink = sprintf(".. _%s:", link);
syntaxText = [];
for s = 1:numel(signatures)
    line = sprintf("| %s\n", signatures{s});
    syntaxText = strcat(syntaxText, line);
end
details = strjoin(details, '\n\n');

rst = strcat(...
    '.. raw:: html\n\n    <pre>\n\n',...                         
    reflink,                 "\n",...
                             '\n',...
    '.. rst-class:: syntax', '\n',...
                             '\n',...
    syntaxText,                   ... trailing newline
                             '\n',...
    '.. raw:: html\n\n    </pre>\n\n',...
    details,                 '\n'...
    );

end
    