function[signatures] = signatureArgs(signatures, title)
%% Inserts links to input/output descriptions in a set of function syntaxes
% ----------
%   signatures = link.signatureArgs(signatures, title)
% ----------
%   Inputs:
%       signatures (string vector): A set of function signatures
%       title (string scalar): The title of the function
%
%   Outputs:
%       signatures (string vector): Function signatures with linked inputs/outputs

% Get inputs and outputs for each syntax
nSyntax = numel(signatures);
inputs = cell(nSyntax, 1);
outputs = cell(nSyntax, 1);
for s = 1:nSyntax
    [inputs{s}, outputs{s}] = parse.args( signatures(s) );
end

% Get the arg keys and reference links
inKeys = link.getKeys(inputs);
inLinks = link.args(title, 'input', inKeys);
outKeys = link.getKeys(outputs);
outLinks = link.args(title, 'output', outKeys);

% Replace keys with links in the funtion signatures
for s = 1:nSyntax
    signatures(s) = link.inputs(signatures(s), inKeys, inLinks);
    signatures(s) = link.outputs(signatures(s), outKeys, outLinks);
end

end