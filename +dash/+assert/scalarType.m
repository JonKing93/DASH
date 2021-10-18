function[] = scalarType(input, type, name, idHeader)
%% dash.assert.scalarType  Throw error if input is not a scalar of a required data type
% ----------
%   dash.assert.scalarType(input, type)  checks if input is scalar and the
%   required data type. If not, throws an error.
%
%   dash.assert.scalarType(input, type, name)  uses a custom name for the
%   input in error messages
%
%   dash.assert.scalarType(input, type, name, idHeader)  uses a custom
%   header for thrown error IDs.
% ----------
%   Inputs:
%       input: The input being tested
%       type (string scalar | empty array): The required data type of the
%           input. Use an empty array to not require a data type
%       name (string scalar): The name of the input in the calling
%           function. Default is "input"
%       idHeader (string scalar): Header for thrown error IDs. Default is
%           "DASH:assert:scalarType"
%
%   Throws:
%       <idHeader>:inputNotScalar  if input is not a scalar
%       <idHeader>:inputWrongType  if input is not the required data type
%
%   <a href="matlab:dash.doc('dash.assert.scalarType')">Online Documentation</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:assert:scalarType";
end

% Scalar
if ~isscalar(input)
    id = sprintf('%s:inputNotScalar', idHeader);
    error(id, '%s is not scalar', name);

% Type
elseif ~isempty(type)
    dash.assert.type(input, type, name, "scalar", idHeader);
end

end