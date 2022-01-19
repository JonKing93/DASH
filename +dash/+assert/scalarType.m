function[] = scalarType(input, types, name, idHeader)
%% dash.assert.scalarType  Throw error if input is not a scalar of a required data type
% ----------
%   dash.assert.scalarType(input, types)
%   Checks if input is scalar and an allowed data type. If not, throws an error.
%
%   dash.assert.scalarType(input, types, name)
%   Uses a custom name for the input in error messages
%
%   dash.assert.scalarType(input, types, name, idHeader)  
%   Uses a custom  header for thrown error IDs.
% ----------
%   Inputs:
%       input: The input being tested
%       types (string vector | []): The allowed data types of the
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
elseif ~isempty(types)
    dash.assert.type(input, types, name, "scalar", idHeader);
end

end