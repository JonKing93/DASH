function[inputs, outputs] = args(signature)
%% Names of inputs and outputs in a function signature
% ----------
%   [inputs, outputs] = parse.args(signature)
% ----------
%   Inputs:
%       signature (char vector): A function signature
%
%   Outputs:
%       inputs (string vector): List of input names
%       outputs (string vector): List of output names

% Split signature into input and output blocks
signature = char(signature);
mid = find(signature=='=');
if isempty(mid)
    output = '';
    input = signature;
else
    output = signature(1:mid-1);
    input = signature(mid+1:end);
end

% Get outputs
output = erase(output, ["[","]"," "]);
outputs = strsplit(output, ',');
outputs = string(outputs);

% Get inputs
start = find(input=='(', 1);
stop = find(input==')', 1, 'last');
if isempty(start)
    inputs = {};
else
    input = input(start+1:stop-1);
    input = erase(input, ' ');
    inputs = strsplit(input, ',');
end
inputs = string(inputs);

end