function[] = scalarType(input, type, name, idHeader)
%% dash.assert.scalarType  Throw error if input is not a scalar of a required data type
% ----------
%   dash.assert.scalarType(input, type, name, idHeader)  checks if input is
%   scalar and the required data type. If not, throws an error with custom
%   message and identifier.
% ----------
%   Inputs:
%       input: The input being tested
%       type (string scalar | empty array): The required data type of the
%           input. Use an empty array to not require a data type
%       name (string scalar): The name of the input in the calling function
%       idHeader (string scalar): Header for thrown error IDs
%       typeName (string scalar): Name of the required type for error
%           messages. By default, uses type for error messages.
%
%   Throws:
%       <idHeader>:inputNotScalar  if input is not a scalar
%       <idHeader>:inputWrongType  if input is not the required type
%
%   <a href="matlab:dash.doc('dash.assert.scalarType')">Online Documentation</a>

if ~isscalar(input)
    id = sprintf('%s:inputNotScalar', idHeader);
    error(id, '%s is not scalar', name);
    
elseif ~isempty(type)
    dash.assert.type(input, type, name, "scalar", idHeader);
end

end