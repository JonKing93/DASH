function[rst] = description(link, signature, details)
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
details = strjoin(details, '\n\n');

rst = strcat(...
    reflink,                 "\n",...
                             '\n',...
    '.. rst-class:: syntax', '\n',...
                             '\n',...
    signature,               '\n',...
                             '\n',...
    details,                 '\n'...
    );

end
    