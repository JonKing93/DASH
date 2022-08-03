function[indices] = additiveIndices(indices, name, header)
%% dash.assert.additiveIndices  Throw error if input is not a vector of additive indices
% ----------
%   indices = dash.assert.additiveIndices(indices)
%   Checks if input is a vector of integers (or empty numeric array). If
%   not, throws an error. If so returns the input and converts empty arrays
%   to true empty.
%
%   indices = dash.assert.additiveIndices(indices, name, header)
%   Customize thrown error messages and IDs.
% ----------
%   Inputs:
%       indices: The input being tested
%       name (string scalar): The name to use for the input in error messages
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       indices (vector, integers | []): The additive indices
%
% <a href="matlab:dash.doc('dash.assert.additiveIndices')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:additiveIndices";
end

% Require numeric type
try
    dash.assert.type(indices, "numeric", name, 'vector', header);

    % Allow empty or vector. Convert empty to true empty
    if isempty(indices)
        indices = [];
        return
    else
        dash.assert.vectorTypeN(indices, [], [], name, header);
    end

    % Require values to be integers
    dash.assert.integers(indices, name, header);

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end