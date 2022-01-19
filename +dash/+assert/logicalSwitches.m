function[] = logicalSwitches(input, nSwitches, name, header)
%% dash.assert.logicalSwitches  Throw error if input is neither a scalar logical nor a logical vector
% ----------
%   dash.assert.logicalSwitches(input, nSwitches)
%   Checks that an input is either a scalar logical, or a logical vector of
%   a given length. Throws an error if neither of these conditions is met.
%
%   dash.assert.logicalSwitches(input, nSwitches, name, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       input: The input being checked
%       nSwitches (scalar positive integer | []): The required length of a
%           logical vector.
%       name (string scalar): The name of the variable being checked.
%       header (string scalar): Header for thrown error IDs.
%
% <a href="matlab:dash.doc('dash.assert.logicalSwitches')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:parse:logicalSwitches";
end

% Require logical
dash.assert.type(input, 'logical', name, [], header);

% If not scalar, check vector length
if ~isscalar(input)
    name = sprintf('Since %s is not scalar, it', name);
    dash.assert.vectorTypeN(input, [], nSwitches, name, header);
end

end