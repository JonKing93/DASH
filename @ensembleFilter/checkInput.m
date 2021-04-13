function[nDim1, nDim2, nDim3] = checkInput(X, name, allowNaN, requireMatrix)
%% Error checks an input as numeric, real, defined, and not empty.
% Optionally checks for a matrix and optionally allows NaN. Returns input
% size.
%
% [nDim1, nDim2, nDim3] = ensembleFilter.checkInput(X, name, allowNaN, requireMatrix)
%
% ----- Inputs -----
%
% X: The input being checked. Either M, D, R, or Y
%
% name: The name of the input being checked. A string
%
% allowNaN: Scalar logical indicating whether to allow NaN values
%
% requireMatrix: Scalar logical indicating whether to require the input to
%    be a matrix.
%
% ----- Outputs -----
%
% nDim1, nDim2, nDim3: The size of dimensions 1, 2 and 3 for the input.

% Defaults
if ~exist('allowNaN','var') || isempty(allowNaN)
    allowNaN = false;
end
if ~exist('requireMatrix','var') || isempty(requireMatrix)
    requireMatrix = false;
end

% Numeric
assert(isnumeric(X), sprintf('%s must be numeric', name));

% Optionally check for matrix
if requireMatrix
    assert(ismatrix(X), sprintf('%s must be a matrix', name));
end

% No Inf or complex, optionally allow NaN
dash.assertRealDefined(X, name, allowNaN);

% No empty arrays (they break size checks)
assert(~isempty(X), sprintf('%s cannot be empty', name));

% Return sizes
[nDim1, nDim2, nDim3] = size(X);

end