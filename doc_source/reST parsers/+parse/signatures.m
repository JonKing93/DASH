function[hasInputs, hasOutputs] = signatures(signatureBlocks)
%% parse.signatures  Determines whether there are inputs and outputs from a set of syntax signature blocks
% ----------
%   [hasInputs, hasOutputs] = parse.signatures(signatureBlocks)
%   Parses a set of signature blocks and determines wheter there any inputs
%   or outputs.
% ----------
%   Inputs:
%       signatureBlocks (string vector): A set of syntax signature blocks.
%
%   Outputs:
%       hasInputs (scalar logical): Whether any of the signatures have inputs
%       hasOutputs (scalar logical): Whether any of the signatures have outputs

% Initialize
hasInputs = false;
hasOutputs = false;

% Get the signatures in each block
for b = 1:numel(signatureBlocks)
    signatures = split(signatureBlocks(b), newline);

    % Find the midpoint of each signature
    for s = 1:numel(signatures)
        signature = char(signatures(s));
        midpoint = find(signature == '=');

        % Scan for outputs
        if ~hasOutputs && ~isempty(midpoint)
            hasOutputs = true;
        end

        % Scan for inputs
        if ~hasInputs
            if isempty(midpoint)
                inputs = signature;
            else
                inputs = signature(midpoint+1:end);
            end
            start = find(inputs=='(', 1, 'first');
            if ~isempty(start)
                hasInputs = true;
            end
        end

        % Exit if verified
        if hasInputs && hasOutputs
            return
        end
    end
end

end