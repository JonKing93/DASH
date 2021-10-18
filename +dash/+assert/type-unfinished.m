function[] = type(input, type, name, idHeader, typeName)
%% dash.assert.type  Throw error if input is not the required type
% ----------
%   dash.assert.type(input, type)  checks if input is the required data
%   type. If not throws an error.
%
%   dash.assert.type(input, type, name)
%   Uses a custom name for the input in thrown error messages.
%
%   dash.assert.type(input, type, name, idHeader)
%   Use a custom header in thrown error IDs
%
%   dash.assert.type(input, type, name, idHeader, typeName)
%   Use a custom name to refer to the required type in error messages.
% ----------
%   Inputs:
%       input: The input being tested
%       type (string scalar): The required data type of the input.
%       name (string scalar): The name of the input in the calling
%           function for use in error messages. Default is "input".
%       idHeader (string scalar): Header for thrown error IDs. Default is
%           "DASH:assert:type"
%       typeName (string scalar): Name of the required type for error
%           messages. By default, uses type.
% 
%   Throws:
%       <idHeader>:inputWrongType  if input is not the required type
%
%   <a href="matlab:dash.doc('dash.assert.type')">Online Documentation</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:assert:type";
end
if ~exist('typeName','var') || isempty(typeName)
    typeName = type;
end

% Throw error if not the required type
if ~isa(input, type)  
    id = sprintf('%s:inputWrongType', idHeader);
    error(id, '%s must be a %s, but it is a %s instead',...
        name, typeName, class(input));
end

end