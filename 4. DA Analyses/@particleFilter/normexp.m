function[Y] = normexp( X, dim, nanflag )
%% Normalizes a set of exponentials by the sum of all exponentials.
% Uses an alternative formulation to avoid directly computing exponentials
% of large magnitude numbers, thereby increasing numerical stability.
%
% Y = normexp( X )
% Given the set of exponents, returns the normalized values for each e^Xi.
% Uses the formulation: exp( Xi - log(sum(exp(Xi))) )
%
% Y = normexp( X, dim )
% Specifies a dimension over which to normalize. Default is dimension 1.
%
% Y = normexp( X, 'all' )
% Normalizes over the entire array.
%
% Y = normexp( X, dim, nanflag )
% Specifies how to treat NaN values. Default is to include NaN in
% normalizations.
%
% ----- Inputs -----
%
% X: A vector or array with the exponents of e^X1, e^X2, ... e^Xn
%
% dim: A scalar integer indicating the dimension along which to sum.
%      Default is the first dimension.
%
% nanflag: A string indicating how to treat NaN values in sums
%       "includenan": (default) Sums containing NaN will evaluate to NaN.
%       "omitnan": Remove all terms with NaN exponents from each sum.
%
% ----- Outputs -----
%
% Y: The normalized exponentials.

% ----- Written By -----
% Jonathan King

% Set defaults. Error check inputs.
if ~exist('dim','var') || isempty(dim)
    dim = 1;
end
if ~exist('nanflag','var') || isempty(nanflag)
    nanflag = "includenan";
end
errorCheck( X, dim, nanflag );

% Compute the normalized values using the log sum of exponentials
m = max(X, [], dim);
lse = m + log( sum(   exp(X - m), dim, nanflag ) );
Y = exp( X - lse );

end

% Error checker
function[] = errorCheck( X, dim, nanflag )

if ~isnumeric(X) || ~isreal(X)
    error('X must be a real, numeric array.');
elseif ((ischar(dim) && isrow(dim)) || (isstring(dim) && isscalar(dim))) && ~strcmp(dim,'all')
        error('Unrecognized string in second input. Perhaps you misspelled "all"?');
elseif (~isnumeric(dim) || ~isreal(dim) || ~isscalar(dim) || dim<1 || mod(dim,1)~=0) && ~( (ischar(dim) && isrow(dim)) || (isstring(dim) && isscalar(dim)) )
    error('dim must be a positive, scalar integer.');
elseif ~( (ischar(nanflag) && isrow(nanflag)) || (isstring(nanflag) && isscalar(nanflag)) )
    error('nanflag must be a string scalar or character row vector.');
elseif ~strcmp(nanflag, "includenan") && ~strcmp(nanflag, "omitnan")
    error('Unrecognized nanflag. It may be misspelled. Valid options are "omitnan" and "includenan".');
end
end
