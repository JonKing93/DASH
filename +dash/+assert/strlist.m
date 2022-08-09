function[list] = strlist(input, name, idHeader)
%% dash.assert.strlist  Throw error if input is not a string vector, cellstring vector, or char row vector
% ----------
%   list = dash.assert.strlist(input)
%   Checks if input is a string vector, cellstring vector, or char row vector.
%   If so, returns the input as a string vector. If not, throws an error.
%
%   list = dash.assert.strlist(input, name)
%   Use a custom name to refer to variable in the error message.
%
%   list = dash.assert.strlist(input, name, idHeader)
%   Use a custom header for thrown error IDs.
% ----------
%   Inputs:
%       input (any data type): The input being tested
%       name (string scalar): The name of the input in the calling
%           function. Default is "input"
%       idHeader (string scalar): A header for thrown error IDs. Default is
%           "DASH:assert:strlist"
%
%   Outputs:
%       list (string vector): The input converted to string data type
%
%   Throws:
%       <idHeader>:inputNotStrlist  when input is not a strlist
%
% <a href="matlab:dash.doc('dash.assert.strlist')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:assert:strlist";
end

% Check input type
if ~dash.is.strlist(input)
    id = sprintf('%s:inputNotStrlist', idHeader);
    ME = MException(id, '%s must be a string vector, cellstring vector, or character row vector', name);
    throwAsCaller(ME);
end

% Convert to string
if nargout>0
    list = string(input);
end

end