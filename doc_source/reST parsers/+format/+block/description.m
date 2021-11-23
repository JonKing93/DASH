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
signatures = strjoin(signatures, '\n');
details = strjoin(details, '\n\n');

rst = strcat(...
    reflink,                 "\n",...
                             '\n',...
    '.. rst-class:: syntax', '\n',...
                             '\n',...
    signatures,               '\n',...
                             '\n',...
    details,                 '\n'...
    );

end
    