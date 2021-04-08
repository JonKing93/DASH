function[] = assertScalarType(input, name, type, typeName)
%% Checks that an input is a scalar of a particular class. Throws a custom
% error message if not.
%
% dash.assertScalarType(input, name, type, typeName)
%
% ----- Inputs -----
%
% input: The input being checked
%
% name: The name of the input. A string. Used for error message.
%
% type: The required class type of the input. A string
%
% typeName: The name used to reference the type. Used for error messages. A
%    string.

if ~isscalar(input) || ~isa(input, type)
    error('%s must be a %s scalar.', name, typeName);
end

end