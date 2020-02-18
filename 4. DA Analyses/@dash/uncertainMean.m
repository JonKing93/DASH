function[E, sigma] = uncertainMean( X, Xvar, dim, weights )
%% Calculates the mean of uncertain, correlated variables and propagates error.
%
% *** THIS IS A PROTOTYPE. IT MAY CHANGE WITHOUT WARNING IN THE FUTURE. ***
%
% Uses the first order, second moment approximations to propagate error.
% Assumes observations along the mean dimension are independent and
% calculates correlation coefficients along this dimension.
%
% [E, sigma] = uncertainMean( X, Xvar )
% Calculates the mean and associated uncertainty for data X with associated
% variance Xvar. Takes the mean along the first dimension.
%
% [E, sigma] = uncertainMean( X, Xvar, dim )
% Specify which dimension to take the mean along.
%
% [E, sigma] = uncertainMean( X, Xvar, dim, weights )
% Propagate error for a weighted mean.
%
% ----- Inputs -----
%
% X: An N-dimensional data array.
%
% Xvar: An N-dimensional array specifying the variance in of each element
%       in X. Must be the same size as X.
%
% dim: A scalar positive integer specifying the dimension over which to
%      take the mean.
%
% weights: Weights for a weighted mean. Must be a singleton in the mean
%          dimension, and match the size of all other dimensions of X.
% 
% ----- Outputs -----
%
% E: The mean.
%
% sigma: The standard deviation of each value in the mean.

warning('This function is a prototype. It may change without warning in the future.');

% Set defaults. First dimension. Unweighted mean.
if ~exist('dim','var') || isempty(dim)
    dim = 1;
end
if ~exist('weights','var') || isempty(weights)
    siz = size(X);
    siz(dim) = 1;
    weights = (1/prod(siz)) * ones( siz );
end

% Error check
if ~isnumeric(dim) || ~isscalar(dim) || dim<=0 || mod(dim,1)~=0
    error('dim must be a scalar, positive integer.');
elseif ~isnumeric(X) || any(isnan(X),'all') || any(isinf(X),'all')
    error('X must be a numeric array and cannot contain NaN or Inf.');
elseif ~isnumeric(Xvar) || any(isnan(Xvar),'all') || any(isinf(Xvar),'all') || any(Xvar<0,'all')
    error('Xvar must be numeric array and cannot contain NaN, Inf, or negative values.');
elseif ~isnumeric(weights) || any(isnan(weights),'all') || any(isinf(weights),'all') || any(weights<0,'all')
    error('weights must be a numeric array and cannot contain NaN, Inf, or negative values.');
elseif ~isequal( size(X), size(Xvar) )
    error('X and Xvar must be the same size.');
end

sizeX = size(X);
sizeWeight = size( weights );
maxDims = max( dim, ndims(X) );
sizeX( end+1:maxDims ) = 1;
sizeWeight( end+1:maxDims ) = 1;
if ~isequal( size(X), size(Xvar) )
    error('X and Xvar must be the same size.');
elseif ~isequal( sizeX([1:dim-1,dim+1:end]), sizeWeight([1:dim-1,dim+1:end]) ) || sizeWeight(dim)~=1
    error('weights must be a singleton in the mean dimension, and the same size as X in all other dimensions.');
end

% Weight the variance. Get the sum of the weights
Xvar = weights.^2 .* Xvar;
w = sum( weights, 'all' );

% Move the mean dimension to the first dimension
dimOrder = 1:ndims(X);
dimOrder(1) = dim;
dimOrder(dim) = 1;

X = permute( X, dimOrder );
Xvar = permute( Xvar, dimOrder );

% Reshape to 2D matrix, each column is a variable
siz = size(Xvar);
newSize = [siz(1), prod(siz(2:end))];

X = reshape( X, newSize );
Xvar = reshape( Xvar, newSize );

% Compute the mean. Preallocate sigma
weights = weights(:)';
E = sum( X.*weights, 2 ) ./ w; 
sigma = NaN( siz(1), 1 );

% Get the upper triangular portion of the correlation matrix
rho = triu( corr(X), 1 );

% Optimize the progress bar
hundredth = ceil( siz(1) / 100 );
progressbar(0);

% Propagate the errors in each time step
for t = 1:siz(1)
    Xsigma = sqrt( Xvar(t,:) );
    sigma(t) = (1/w) * sqrt( sum(Xvar(t,:),2) + 2*( Xsigma * rho * Xsigma' ) );
    
    if mod(t, hundredth)==0 || t==siz(1)
        progressbar(t/siz(1));
    end
end

end