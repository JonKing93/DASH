function[nDim1, nDim2, nDim3] = checkInput(X, name, isDR)
%% Error checks M, D, R, and Y and returns sizes
%
% [nDim1, nDim2, nDim3] = kalmanFilter.errorCheckInput(X, name, isDR)
%
% ----- Inputs -----
%
% X: The input being checked. Either M, D, R, or Y
%
% name: The name of the input being checked. A string
%
% isDR: Scalar logical that indicates whether the input is D or R.
%
% ----- Outputs -----
%
% nDim1, nDim2, nDim3: The size of dimensions 1, 2 and 3 for the input.

% Defaults
if ~exist('isDR','var') || isempty(isDR)
    isDR = false;
end

% Extra checks for D and R
allowNaN = false;
requireMatrix = false;
if isDR
    allowNaN = true;
    requireMatrix = true;
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