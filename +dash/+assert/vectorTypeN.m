function[] = vectorTypeN(input, type, length, name, idHeader)
%% dash.assert.vector  Throws error if input is not a vector of a specified format
% ----------
%   dash.assert.vectorTypeN(input, type, length, name, idHeader)
%   Checks if an input is a vector of the specified type and length. If
%   not, throws an error with custom message and ID.
% ----------
%   Inputs:
%       input: The input being tested
%       type (string scalar | empty array): The required data type of the
%           input. Use an empty array to allow any type
%       length (scalar positive integer | empty array): The required length
%           of the vector. Use an empty array to allow any length
%       name (string scalar): The name of the input in the calling function
%       idHeader (string scalar): Header for thrown error IDs
%
%   Throws:
%       <idHeader>:<name>NotVector  when input is not a vector
%       <idHeader>:<name>WrongType  when input is not the required type
%       <idHeader>:<name>WrongLength  when input is not the required length
%
%   <a href="matlab:dash.doc('dash.assert.vectorTypeN')">Online Documentation</a>

% Vector
if ~isvector(input)
    id = sprintf('%s:%sNotVector', idHeader, name);
    error(id, '%s is not a vector', name);

% Type
elseif ~isempty(type) && ~isa(input, type)
    id = sprintf('%s:%sWrongType', idHeader, name);
    error(id, '%s must be a %s vector, but it is a %s vector instead', ...
        name, type, class(input));
    
% Length
elseif ~isempty(N) && length(input)~=N
    id = sprintf('%s:%sWrongLength', idHeader, name);
    error(id, '%s must have %.f elements, but has %.f elements instead', ...
        name, N, length(input));
end

end