function[signature] = outputs(signature, keys, links)
%% Insert links to output descriptions in a function signature
% ----------
%   signature = link.outputs(signature, keys, links)
% ----------
%   Inputs:
%       signature (string scalar): A function signature
%       keys (string vector [nOutput]): List of outputs to link in the signature
%       links (string vector [nOutput]): The link for each output
%
%   Outputs:
%       signature (string scalar): The signature with linked outputs

% Require an output block
signature = char(signature);
mid = signature=='=';
if ~any(mid)
    signature = string(signature);
    return;
end

% Limits of output blocks with brackets
if any(signature=='[')
    start = find(signature=='[')+1;
    stop = find(signature==']')-1;
    
% Without brackets (only a single output)
else
    start = find(isletter(signature), 1);
    argEnd = find(signature==' ' | signature==',' | signature==']' | signature=='=');
    firstEnd = find(argEnd>start, 1);
    stop = argEnd(firstEnd) - 1;
end

% Replace outputs with reference links
outputs = signature(start:stop);
outputs = link.keys(outputs, keys, links);
signature = [signature(1:start-1), outputs, signature(stop+1:end)];
signature = string(signature);

end