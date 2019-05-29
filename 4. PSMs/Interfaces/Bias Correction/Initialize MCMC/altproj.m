function[X, dist, converged] = altproj( A, varargin )
%% Implements a naive alternating projection algorithm to find the nearest 
% valid (positive semi-definite) matrix. (Higham, 2002)
%
% Typically used to find the nearest valid correlation matrix to an
% "approximate" correlation matrix generated for data with missing values.
%
% [X, dist, converged] = altproj( A )
% Finds the nearest correlation matrix to matrix A within machine
% precision. Also returns the distance between A and X for three
% convergence criteria.
%
% [...] = altproj( A, tol )
% Finds the nearest correlation matrix within a user-defined tolerance.
% Default is machine precision.
%
% [...] = altproj( A, tol, maxIter )
% Specify a maximum number of iterations. Default is 1000.
%
% [...] = altproj( A, tol, maxIter, weight )
% Specify the elements of a diagonal weighting matrix. Default is no
% weighting.
%
% ----- Inputs -----
%
% A: An approximate correlation matrix. (Typically via the 'rows',
%   'pairwise' options for the corr function for data with missing
%   elements.)  (N x N)
% 
% tol: A scalar convergence tolerance. Leave empty to use the default. (1 x 1)
%
% maxIter: A maximum number of iterations. Default is 1000.
%
% weight: A vector containing elements for a diagonal weighting matrix. (N x 1)
%
% ----- Outputs -----
%
% X: The nearest valid (positive semi-definite) correlation matrix to A. (N x N)
%
% dist: The distance threholds from Higham, 2002 for each iteration. (nIter x 3)
%
% converged: A boolean reporting whether the method converged 

% ----- References -----
%
% Higham, N. J. (2002). Computing the nearest correlation matrix—a problem
% from finance. IMA journal of Numerical Analysis, 22(3), 329-343. 
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the inputs. Get defaults for unspecified values
[tol, maxIter, w] = setup(A, varargin);

% Get the square root of the weighting matrix and its size
sqW = sqrt( w * w' );
n = length(w);

% Preallocate the convergence tests
dist = NaN( maxIter, 3 );
converged = false;

% Initialize Dykstra's correction and the iterated matrices.
dS = 0;
Y = A;
X = A;

% For each iteration
for k = 1:maxIter
    
    % Save the previous values of X and Y (to test convergence)
    Xold = X;
    Yold = Y;
    
    % Apply Dykstra's correction
    R = Y - dS;
    
    % Project onto S, the set of symmetric, positive semi-definite matrices
    X = projectS( R, sqW );
    
    % Update Dykstra's correction
    dS = X - R;
     
    % Project onto U, the set of symmetric matrices with unit diagonal
    Y = projectU( X, n );
    
    % Do the convergence tests
    dist(k, 1) = norm( X - Xold, 'fro' ) / norm(X, 'fro');
    dist(k, 2) = norm( Y - Yold, 'fro' ) / norm(Y, 'fro');
    dist(k, 3) = norm( Y - X, 'fro' ) / norm(Y, 'fro');
    
    % If the tests are less than the convergence threshold
    if max( dist(k,:) ) < tol
        
        % Remove extra iterations
        dist(k+1:end, :) = [];
        
        % Mark as converged
        converged = true;
        
        % Stop iterating
        break;
    end
end 

end

%% Project a matrix onto S, the set of symmetric, positive semi-definite matrices
function[Y] = projectS( R, sqW )

% Weight the corrected matrix
Y = R .* sqW;

% Get the eigenvalue decomposition
[Q, D] = eig(Y);

% Convert negative eigenvalues to 0
D( D<0 ) = 0;

% Get the weighted matrix with adjusted eigenvalues
Y = Q * D * Q';

% Unweight the projection
Y = Y ./ sqW;

end


%% Project a matrix onto U, the set of symmetric matrices with unit diagonal
function[X] = projectU( X, n )

% Convert all the diagonal elements to 1
X( 1: n+1: n^2 ) = 1;

end

%% Helper function that checks the inputs for errors.
function[tol, maxIter, w] = setup(A, inArgs)

% Check that A is a square matrix
if ~ismatrix(A)
    error('A must be a matrix.');
elseif size(A,1) ~= size(A,2)
    error('A must be a square matrix.');
elseif ~isnumeric(A) || any(isnan(A(:))) || any(isinf(A(:)))
    error('A must be a numeric matrix and cannot contain NaN or Inf values.');
elseif ~issymmetric(A)
    error('A must be a symmetric matrix.');
end

% Check the number of inputs
if numel(inArgs) > 3
    error('Too many inputs');
end

% Get tol
if numel(inArgs) == 0
    tol = eps;   % Machine precision default
else
    tol = inArgs{1};
end    

% Error check tol
if ~isscalar(tol) || ~isnumeric(tol) || ~isreal(tol)
    error('tol must be a numeric, real-valued scalar');
elseif tol <= 0 
    error('tol must be larger than 0.');
end

% Get the maximum number of iterations
if numel(inArgs) < 2
    maxIter = 1000;
else
    maxIter = inArgs{2};
end

% Error check maxIter
if ~isscalar(maxIter) || ~isnumeric(maxIter) || ~isreal(maxIter) || maxIter <= 0 || mod(maxIter,1)~=0
    error('maxIter must be a scalar positive integer.');
end

% Get w
if numel(inArgs) < 3
    w = ones( size(A,1), 1 );
else
    w = inArgs{3};
end

% Error check w
if ~isvector(w) || ~isnumeric(w) || length(w)~=size(A,1)
    error('w must be a numeric vector with an element for each row of A.');
elseif any( w<=0 ) || any( isnan(w)) || any(isinf(w))
    error('All elements in w must be positive and neither infinite nor NaN.');
end

% Convert w to column vector
w = w(:);

end