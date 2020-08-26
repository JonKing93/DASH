function[] = assertPositiveIntegers(input, allowNaN, allowInf, name)
%% Checks that an input consists of positive integers. Optionally allows
% NaN and Inf values. Returns customized error messages.
%
% dash.assertPositiveIntegers(input, allowNaN, allowInf, name)
%
% ----- Inputs -----
%
% input: The input being checked
%
% allowNaN: A scalar logical. Whether to allow NaN values in the input.
%
% allowInf: A scalar logical. Whether to allow Inf values in the input.
%
% name: The name of the input. Used for custom error messages.

% Require numeric
if ~isnumeric(input)
    error('%s must be numeric', name);
end

% Process NaN and Inf
dash.assertRealDefined(input, name, allowNaN, allowInf);
input(isnan(input)) = 1;
input(isinf(input)) = 1;

% Check for positive integers
if any(input<1,'all') || any(mod(input,1)~=0,'all')
    error('%s must only contain positive integers.', name);
end
    
end