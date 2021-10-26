function[signatures] = signatureArgs(signatures, title, inputs, outputs)
%% Inserts links to input/output descriptions in a set of function syntaxes
% ----------
%   signatures = link.signatureArgs(signatures, title)
% ----------
%   Inputs:
%       signatures (string vector): A set of function signatures
%       title (string scalar): The title of the function
%       inputs (string vector): List of input names
%       outputs (string vector): List of output names
%
%   Outputs:
%       signatures (string vector): Function signatures with linked inputs/outputs

% Get the arg keys and reference links
inputLinks = link.args(title, 'input', inputs);
outputLinks = link.args(title, 'output', outputs);

% Replace keys with links in the funtion signatures
for s = 1:nSyntax
    signatures(s) = link.inputs(signatures(s), inputs, inputLinks);
    signatures(s) = link.outputs(signatures(s), outputs, outputLinks);
end

end