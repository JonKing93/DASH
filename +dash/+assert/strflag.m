function[input] = strflag(input, name, idHeader)
%% Throws an error if an input is not a string flag.
% If the input is a string flag, returns it as a "string" data type.
% Otherwise, returns a custom error message and ID using the input's name.
%
% str = dash.assert.strflag(input, name, idHeader)
%
% ----- Inputs -----
%
% input: An input being checked.
%
% name: The name of the input. A string scalar
%
% idHeader: Header for the error ID. A string scalar
%
% ----- Outputs -----
%
% str: The input as a string data type.

if ~dash.is.strflag(input)
    id = sprintf('%s:%sNotStrflag', idHeader, name);
    error(id, '%s must be a string scalar or character row vector', name);
end

if nargout>0
    input = string(input);
end
    
end