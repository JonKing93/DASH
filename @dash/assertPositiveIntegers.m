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

% Process NaNs
if allowNaN
    input(isnan(input)) = 1;
elseif any(isnan(input),'all')
    error('%s may not contain NaN.', name);
end

% Process Inf
if allowInf
    input(isinf(input)) = 1;
elseif any(isinf(input),'all')
    error('%s may not contain Inf.', name);
end

% Everything else
if ~isnumeric(input) || ~isreal(input) || any(input<1,'all') || any(mod(input,1)~=0,'all')
    error('%s can only contain positive integers.', name);
end
    
end