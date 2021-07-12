function[] = positiveIntegers(input, name, allowNaN, allowInf)
%% Checks that an input consists of positive integers. Optionally allows
% NaN and Inf values. Returns customized error messages.
%
% dash.assertPositiveIntegers(input, name)
% Checks the input consists of positive integers. Does not allow NaN or Inf
%
% dash.assertPositiveIntegers(input, name, allowNaN, allowInf)
% Specify whether to allow NaN or Inf.
%
% ----- Inputs -----
%
% input: The input being checked
%
% name: The name of the input. A string. Used for custom error messages.
%
% allowNaN: A scalar logical that indicates whether to allow NaN values in
%    the input (true) or not (false -- default). 
%
% allowInf: A scalar logical that indicates whether to allow Inf values in
%    the input (true) or not (false -- default).

% Defaults
if ~exist('allowNaN','var') || isempty(allowNaN)
    allowNaN = false;
end
if ~exist('allowInf','var') || isempty(allowInf)
    allowInf = false;
end

% Require numeric
if ~isnumeric(input)
    error('%s must be numeric', name);
end

% Process NaN and Inf
dash.assert.realDefined(input, name, allowNaN, allowInf);
input(isnan(input)) = 1;
input(isinf(input)) = 1;

% Check for positive integers
if any(input<1,'all') || any(mod(input,1)~=0,'all')
    error('%s must only contain positive integers.', name);
end
    
end