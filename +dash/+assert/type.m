function[] = type(input, type, name, descriptor, idHeader)
%% dash.assert.type  Throw error if input is not required type
% ----------
%   dash.assert.type(input, type)  checks if input is the required data
%   type. If not, throws an error.
%
%   dash.assert.type(input, type, name, descriptor)  uses a custom name and
%   data type descriptor in thrown error messages.
%
%   dash.assert.type(input, type, name, descriptor, idHeader)  uses a custom
%   header in thrown error IDs.
% ----------
%   Inputs:
%       input: The input being tested
%       type (string scalar): The required data type
%       name (string scalar): The name of the input in the calling
%           function for use in error messages. Default is "input"
%       descriptor (string scalar): Descriptor for data type in error
%           messages. Default is "data type"
%       idHeader (string scalar): Header for thrown error IDs. Default is
%           "DASH:assert:type"
%
%   Throws:
%       <idHeader>:inputWrongType  if input is not the required type
%
%   <a href="matlab:dash.doc('dash.assert.type')">Online Documentation</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('spec','var') || isempty(descriptor)
    descriptor = "data type";
end
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:assert:type";
end

% Throw error if incorrect type
if ~isa(input, type)
    id = sprintf('%s:inputWrongType', idHeader);
    error(id, '%s must be a %s %s, but it is a %s %s instead',...
        name, type, descriptor, class(input), descriptor);
end

end