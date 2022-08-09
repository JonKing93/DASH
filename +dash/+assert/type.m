function[] = type(input, types, name, descriptor, idHeader)
%% dash.assert.type  Throw error if input is not an allowed data type
% ----------
%   dash.assert.type(input, types)
%   Checks if input is the required data type. If not, throws an error.
%
%   dash.assert.type(input, types, name, descriptor)  
%   Uses a custom name and data type descriptor in thrown error messages.
%
%   dash.assert.type(input, types, name, descriptor, idHeader)  
%   Uses a custom header in thrown error IDs.
% ----------
%   Inputs:
%       input (any data type): The input being tested
%       types (string vector): The allowed data types
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
% <a href="matlab:dash.doc('dash.assert.type')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('descriptor','var') || isempty(descriptor)
    descriptor = "data type";
end
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:assert:type";
end

% Exit if input matches any type category
types = string(types);
for t = 1:numel(types)
    if isa(input, types(t))
        return;
    end
end

% Throw error if no matches
types = dash.string.list(types, "or");
id = sprintf('%s:inputWrongType', idHeader);
ME = MException(id, '%s must be a %s %s, but it is a "%s" %s instead',...
    name, types, descriptor, class(input), descriptor);
throwAsCaller(ME);

end