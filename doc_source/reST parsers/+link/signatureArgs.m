function[signatureBlocks] = signatureArgs(signatureBlocks, inputNames, inputLinks, outputNames, outputLinks)
%% link.signatureArgs  Insert links to input/output args in a set of syntax signatures
% ----------
%   signatureBlocks = link.signatureArgs(signatureBlocks, inputNames, inputLinks, outputNames, outputLinks)
%   Given a block of syntax signatures, links input/output arguments in the
%   signatures to their descriptions.
% ----------
%   Inputs:
%       signatureBlocks (string vector [nSyntax]): Signature blocks for
%           different sytnaxes. Different signatures in the same block are
%           separated by newlines.
%       inputNames (string vector [nInputs]): The names of input arguments
%       inputLinks (string vector [nInputs]): Reference links to the inputs
%       outputNames (string vector [nOutputs]): The names of output arguments
%       outputLinks (string vector [nOutputs]): Reference links to the output arguments
%
%   Outputs:
%       signatureBlocks (string vector [nSyntax]): Updated signature
%           blocks wherein the names of input/output arguments have been
%           replaced with reference links.

% Get the signatures in each block
for b = 1:numel(signatureBlocks)
    signatures = split(signatureBlocks(b), newline);

    % Replace input/output names with links in each signature
    for s = 1:numel(signatures)
        signatures(s) = replaceInputs(signatures(s), inputNames, inputLinks);
        signatures(s) = replaceOutputs(signatures(s), outputNames, outputLinks);
    end

    % Update the signature blocks
    signatureBlocks(b) = join(signatures, newline);
end

end

%% Utility functions
function[signature] = replaceInputs(signature, names, links)

% Get the limits of the input block
signature = char(signature);
start = find(signature=='(', 1)+1;
stop = find(signature==')', 1)-1;

% Replace inputs with links
if ~isempty(start)
    inputs = signature(start:stop);
    inputs = addArgLinks(inputs, names, links);
    signature = [signature(1:start-1), inputs, signature(stop+1:end)];
end
signature = string(signature);

end
function[signature] = replaceOutputs(signature, names, links)

% Require an output block
signature = char(signature);
mid = find(signature=='=');
if ~any(mid)
    signature = string(signature);
    return;
end

% Split the inputs and outputs
outputs = signature(1:mid-1);
remainder = signature(mid:end);

% Limits of output blocks with brackets
if any(outputs=='[')
    start = find(outputs=='[')+1;
    stop = find(outputs==']')-1;
    
% Without brackets (only a single output)
else
    start = find(isletter(outputs), 1);
    argEnd = find(outputs==' ' | outputs==',' | outputs==']' | outputs=='=');
    firstEnd = find(argEnd>start, 1);
    stop = argEnd(firstEnd) - 1;
end

% Replace outputs with reference links
outputList = outputs(start:stop);
outputList = addArgLinks(outputList, names, links);
outputs = [outputs(1:start-1), outputList, outputs(stop+1:end)];
signature = [outputs, remainder];
signature = string(signature);

end
function[text] = addArgLinks(text, names, links)

% Whitespace pad
text = [' ', text, ' '];

% Use regular expression to find args
for n = 1:numel(names)
    pattern = sprintf("[ ,]%s[ ,]", names(n));
    [start, stop] = regexp(text, pattern);
    replace = sprintf(':ref:`%s <%s>`', names(n), links(n));
    
    % Replace each match with a link
    for s = numel(start):-1:1
        text = [text(1:start(s)), replace, text(stop(s):end)];
    end
end

% Remove whitespace padding
text = text(2:end-1);

end
