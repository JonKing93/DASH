function[] = vectorTypeN(input, type, length, name, idHeader)
%% dash.assert.vector  Throws error if input is not a vector of a specified format
% ----------
%   dash.assert.vectorTypeN(input, type, length)
%   Checks if an input is a vector of the required data type and length. If
%   not, throws an error
%
%   dash.assert.vectorTypeN(input, type, length, name)
%   Use a custom name to refer to the input in error messages.
%
%   dash.assert.vectorTypeN(input, type, length, name, idHeader)
%   Use a custom header for thrown error IDs.
% ----------
%   Inputs:
%       input: The input being tested
%       type (string scalar | empty array): The required data type of the
%           input. Use an empty array to allow any type
%       length (scalar positive integer | empty array): The required length
%           of the vector. Use an empty array to allow any length
%       name (string scalar): The name of the input in the calling
%           function for use in error messages. Default is "input"
%       idHeader (string scalar): Header for thrown error IDs. Default is
%           "DASH:assert:vectorTypeN"
%
%   Throws:
%       <idHeader>:inputNotVector  when input is not a vector
%       <idHeader>:inputWrongType  when input is not the required type
%       <idHeader>:inputWrongLength  when input is not the required length
%
%   <a href="matlab:dash.doc('dash.assert.vectorTypeN')">Online Documentation</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:assert:vectorTypeN";
end

% Vector
if ~isvector(input)
    id = sprintf('%s:inputNotVector', idHeader);
    error(id, '%s is not a vector', name);

% Type
elseif ~isempty(type)
    dash.assert.type(input, type, name, "vector", idHeader);
    
% Length
elseif ~isempty(length) && numel(input)~=length
    id = sprintf('%s:inputWrongLength', idHeader);
    error(id, '%s must have %.f elements, but has %.f elements instead', ...
        name, length, numel(input));
end

end