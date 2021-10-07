function[input] = strlist(input, name, idHeader)
%% dash.assert.strlist  Throws error if input is not a string vector, cellstring vector, or char row vector
%
%   list = dash.assert.strlist(A, name, idHeader)
%   Checks if A is a string vector, cellstring vector, or char row vector.
%   If so, returns A as a string vector. If not, throws an error with
%   custom message and ID.
%
% <a href="matlab:dash.doc('dash.assert.strlist')">Online Documentation</a>

if ~dash.is.strlist(input)
    id = sprintf('%s:%sNotStrlist', idHeader, name);
    error(id, '%s must be a string vector, cellstring vector, or character row vector', name);
end

if nargout>0
    input = string(input);
end

end