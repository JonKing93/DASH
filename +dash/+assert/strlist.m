function[input] = strlist(input, name, idHeader)
%% Throws an error if an input is not a string list.
% If the input is a string list, returns it as a "string" data type. If
% throwing an error, returns a customized error message and ID using the
% input's name.
%
% str = dash.assert.strlist(input, name, idHeader)
%
% ----- Inputs -----
%
% input: The input being checked
%
% name: The name of the input. A string
%
% idHeader: Header for the error ID
%
% ----- Outputs -----
%
% str: The input as a string data type

if ~dash.is.strlist(input)
    id = sprintf('%s:%sNotStrlist', idHeader, name);
    error(id, '%s must be a string vector, cellstring vector, or character row vector', name);
end

if nargout>0
    input = string(input);
end

end