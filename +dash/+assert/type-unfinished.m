function[] = type(input, type, name, idHeader, typeName)
%% dash.assert.type  Throw error if input is not the required type
% ----------
%   dash.assert.type(input, type, name, idHeader)  checks if input is the
%   required data type. If not, throws an error with custom message and
%   identifier.
%
%   dash.assert.type(input, type, name, idHeader, typeName)  use the
%   specified name to refer to the required type in error messages.
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
%       <idHeader>:inputWrongType  if input is not the required type
%
%   <a href="matlab:dash.doc('dash.assert.type')">Online Documentation</a>

if ~isa(input, type)
    if ~exist('typeName','var') || isempty(typeName)
        typeName = type;
    end  
    id = sprintf('%s:inputWrongType', idHeader);
    error(id, '%s must be a %s type, but it is %s instead',...
        name, typeName, class(input));
end

end