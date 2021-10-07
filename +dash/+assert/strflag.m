function[input] = strflag(input, name, idHeader)
%% dash.assert.strflag  Throw error if input is not a string flag
%
%   str = dash.assert.strflag(A, name, idHeader)
%   Checks if A is either a string scalar or char row vector. If not, 
%   throws an error with custom message and ID. If so, returns A as a
%   "string" data type.
%
% <a href="matlab:dash.doc('dash.assert.strflag')">Online Documentation</a>

if ~dash.is.strflag(input)
    id = sprintf('%s:%sNotStrflag', idHeader, name);
    error(id, '%s must be a string scalar or character row vector', name);
end

if nargout>0
    input = string(input);
end
    
end