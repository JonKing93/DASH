function[] = assertRealDefined(input, name, allowNaN, allowInf, allowComplex)
%% Checks that an input is real, not NaN, and not Inf. Optionally allows
% NaN, Inf, or complex. Returns custom error messages.
%
% dash.assertRealDefined(input, name)
% Checks that an input is real, not NaN and not Inf. 
%
% dash.assertRealDefined(input, name, allowNaN, allowInf, allowComplex)
% Optionally allow NaN, Inf, or complex.
%
% ----- Inputs -----
%
% input: The input being checked
%
% name: The name of the input. A string. Used for custom error messages.
%
% allowNaN: Scalar logical indicating whether to allow NaN (true) or not
%    (false -- default)
%
% allowInf: Scalar logical indicating whether to allow Inf (true) or not
%    (false -- default)
%
% allowComplex: Scalar logical indicating whether to allow complex values
%    (true) or not (false -- default)

% Defaults
if ~exist('allowNaN','var') || isempty(allowNaN)
    allowNaN = false;
end
if ~exist('allowInf','var') || isempty(allowInf)
    allowInf = false;
end
if ~exist('allowComplex','var') || isempty(allowComplex)
    allowComplex = false;
end

% Check input
if ~allowNaN && any(isnan(input), 'all')
    error('%s may not contain NaN', name);
elseif ~allowInf && any(isinf(input), 'all')
    error('%s may not contain Inf', name);
elseif ~allowComplex && ~isreal(input)
    error('%s may not contain complex (imaginary) values', name);
end

end