function[rst] = syntax(signatures, links)
%% Format the list of function syntaxes
% ----------
%   rst = format.syntax(signatures, links)
% ----------
%   Inputs:
%       signatures (string vector): List of function signatures/syntaxes
%       links (string vector): Link to the usage details of each syntax
%
%   Outputs:
%       rst: reST markup for the syntax section

% Build each line
syntaxText = [];
for s = 1:numel(signatures)
    line = sprintf("| :ref:`%s <%s>`\n", signatures{s}, links{s});
    syntaxText = strcat(syntaxText, line);
end

% Format rst Section
rst = strcat(...
    "Syntax",                '\n',...
    '------',                '\n',...
                             '\n',...
    '.. rst-class:: syntax', '\n',...
                             '\n',...
    syntaxText,                   ... % trailing newline 
                             '\n',...
    '----',                  '\n',...
                             '\n'...
    );

end