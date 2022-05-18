function[] = vectorTypeN(input, types, length, name, idHeader)
%% dash.assert.vectorTypeN  Throws error if input is not a vector of a specified format
% ----------
%   dash.assert.vectorTypeN(input, types, length)
%   Checks if an input is a vector of the required data type and length. If
%   not, throws an error
%
%   dash.assert.vectorTypeN(input, types, length, name)
%   Use a custom name to refer to the input in error messages.
%
%   dash.assert.vectorTypeN(input, types, length, name, idHeader)
%   Use a custom header for thrown error IDs.
% ----------
%   Inputs:
%       input: The input being tested
%       types (string vector | []): The allowed data types of the
%           input. Use an empty array to allow any type
%       length (scalar positive integer | []): The required length
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
try
    if ~isvector(input)
        id = sprintf('%s:inputNotVector', idHeader);
        error(id, '%s must be a vector', name);
    end

    % Type
    if ~isempty(types)
        dash.assert.type(input, types, name, "vector", idHeader);
    end
    
    % Length
    if ~isempty(length) && numel(input)~=length
        id = sprintf('%s:inputWrongLength', idHeader);
        error(id, '%s must have %.f elements, but it has %.f elements instead.', ...
            name, length, numel(input));
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end