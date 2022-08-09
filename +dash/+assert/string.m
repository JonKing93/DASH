function[str] = string(input, name, header)
%% dash.assert.string  Throw error if input is not a string array, cellstring array, or character row vector
% ----------
%   str = dash.assert.string(input)
%   Checks if an input is either a string array, cellstring array, or char
%   row vector. If not, throws an error. If so, returns the input as a
%   string data type.
%
%   str = dash.assert.string(input, name, header)
%   Customize message and header of thrown errors.
% ----------
%   Inputs:
%       input (any data type): The input being checked
%       name (string scalar): The name of the input in the calling
%           function. Default is "input".
%       header (string scalar): Header for thrown error IDs. Default is
%           "DASH:assert:string"
%
%   Outputs:
%       str (string array): The input converted to a string data type.
%
% <a href="matlab:dash.doc('dash.assert.string')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:string";
end

% Check input type
if ~dash.is.string(input)
    id = sprintf("%s:inputNotString", header);
    ME = MException(id, '%s must be a string array, cellstring array, or character row vector', name);
    throwAsCaller(ME);
end

% Convert to string
if nargout>0
    str = string(input);
end

end