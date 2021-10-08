function[str] = strflag(input, name, idHeader)
%% dash.assert.strflag  Throw error if input is not a string flag
% ----------
%   str = dash.assert.strflag(input, name, idHeader)
%   Checks if an input is either a string scalar or char row vector. If not, 
%   throws an error with custom message and ID. If so, returns the input as
%   a "string" data type.
% ----------
%   Inputs:
%       input: The input being tested
%       name (string scalar): Name of the input in the calling function
%       idHeader (string scalar): Header for thrown error IDs
%
%   Outputs:
%       str (string scalar): The input converted to a string data type
%
%   Throws:
%       <idHeader>:<name>NotStrFlag  when input is not a strflag
%
% <a href="matlab:dash.doc('dash.assert.strflag')">Online Documentation</a>

if ~dash.is.strflag(input)
    id = sprintf('%s:%sNotStrflag', idHeader, name);
    error(id, '%s must be a string scalar or character row vector', name);
end

if nargout>0
    str = string(input);
end
    
end