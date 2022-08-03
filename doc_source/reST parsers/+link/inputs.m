function[signature] = inputs(signature, keys, links)
%% Insert links to inputs into a function signature
% ----------
%   signature = link.inputs(signature, keys, links)
% ----------
%   Inputs:
%       signature (string scalar): A function signature
%       keys (string vector [nInputs]): Names of inputs that should be given links
%       links (string vector [nInputs]): The reference link for each input
%
%   Outputs:
%       signature (string scalar): The signature with linked inputs

% Get limits of the input block
signature = char(signature);
start = find(signature=='(', 1)+1;
stop = find(signature==')', 1)-1;

% Replace inputs with reference links
if ~isempty(start)
    inputs = signature(start:stop);
    inputs = link.keys(inputs, keys, links);
    signature = [signature(1:start-1), inputs, signature(stop+1:end)];
end
signature = string(signature);
    
end