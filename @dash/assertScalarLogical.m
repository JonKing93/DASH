function[] = assertScalarLogical(input, name)
%% Checks that an input is a scalar logical. Throws a custom error message
% if not.
%
% dash.assertScalarLogical(input, name)
%
% ----- Inputs -----
%
% input: The input being checked
%
% name: The name of the input. A string. Used for error message.

if ~isscalar(input) || ~islogical(input)
    error('%s must be a scalar logical.', name);
end

end