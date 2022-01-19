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

if isscalar(switches)
    dash.assert.scalarType(switches, 'logical', name, header);
else
    dash.assert.vectorTypeN(switches, 'logical', nSwitches, name, header);
end

end