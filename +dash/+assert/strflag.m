function[str] = strflag(input, name, idHeader)
%% dash.assert.strflag  Throw error if input is not a string scalar, cellstring scalar, or char row vector.
% ----------
%   str = dash.assert.strflag(input)
%   Checks if an input is either a string scalar, cellstring scalar, or
%   char row vector. If not, throws an error. If so, returns the input as a
%   string data type.
%
%   str = dash.assert.strflag(input, name)
%   Refers to the input by a custom name in thrown error messages.
%
%   str = dash.assert.strflag(input, name, idHeader)
%   Uses a custom header for thrown error IDs.
% ----------
%   Inputs:
%       input: The input being tested
%       name (string scalar): Name of the input in the calling function.
%           Default is "input".
%       idHeader (string scalar): Header for thrown error IDs. Default is
%           "DASH:assert:strflag".
%
%   Outputs:
%       str (string scalar): The input converted to a string data type.
%
%   Throws:
%       <idHeader>:inputNotStrFlag: When input is not a strflag.
%
% <a href="matlab:dash.doc('dash.assert.strflag')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:assert:strflag";
end

% Check input type
if ~dash.is.strflag(input)
    id = sprintf('%s:inputNotStrflag', idHeader);
    ME = MException(id, '%s must be a string scalar or character row vector', name);
    throwAsCaller(ME);
end

% Convert to string
if nargout>0
    str = string(input);
end
    
end