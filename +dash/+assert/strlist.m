function[list] = strlist(input, name, idHeader)
%% dash.assert.strlist  Throws error if input is not a string vector, cellstring vector, or char row vector
% ----------
%   list = dash.assert.strlist(input, name, idHeader)
%   Checks if input is a string vector, cellstring vector, or char row vector.
%   If so, returns the input as a string vector. If not, throws an error with
%   custom message and ID.
% ----------
%   Inputs:
%       input: The input being tested
%       name (string scalar): The name of the input in the calling function
%       idHeader (string scalar): A header for thrown error IDs
%
%   Outputs:
%       list (string vector): The input converted to string data type
%
%   Throws:
%       <idHeader>:<name>NotStrlist  when input is not a strlist
%
% <a href="matlab:dash.doc('dash.assert.strlist')">Online Documentation</a>

if ~dash.is.strlist(input)
    id = sprintf('%s:%sNotStrlist', idHeader, name);
    error(id, '%s must be a string vector, cellstring vector, or character row vector', name);
end

if nargout>0
    list = string(input);
end

end