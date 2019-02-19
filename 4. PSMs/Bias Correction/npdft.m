function[X, E, jR, jXs] = npdft( Xs, Xt, tol, nIter )
%% Performs the N-pdft algorithm.
% Applies bias correction by equating the CDF of N-dimensional source data 
% with an N-dimensional target. Uses the energy distance statistic to
% monitor algorithm convergence.
%
% X = npdft( Xs, Xt, tol )
% Applies the N-pdft alogrithm until the energy distance of the source and
% target data falls below a threshold. Returns the bias-corrected output.
%
% X = npdft( Xs, Xt, tol, nIter )
% Sets a maximum number of allowed iterations.
%
% [X, E] = npdft( ... )
% Also returns the energy statistic for each iteration.
%
% [X, E, jR, jXs] = npdft( ... )
% Also returns the rotation matrix and rotated Xs values for each iteration
%
% ----- Inputs -----
%
% Xs: Source data
%
% Xt: Target data
%
% tol: threshold to use for convergence.
%
% nIter: A maximum number of iterations.
%
% ----- Outputs -----
%
% X: The bias corrected source data.
%
% E: The energy statistic for each rotation.
%
% jR: The rotation matrix used for each iteration.
%
% jXs: The rotated source data for each iteration.

% Check that Xs and Xt are matrices
if ~ismatrix(Xs) || ~ismatrix(Xt)
    error('Xs and Xt must be matrices.');
end

% Both must have the same number of variables
N = size(Xs,2);
if N ~= size(Xt,2)
    error('Xs and Xt must have the same number variables (columns).');
end

% Set nIter to infinite if not specified
if nargin < 4
    nIter = Inf;
end

% Initialize optional outputs
E = [];
jR = [];
jXs = [];

% Standardize both datasets
Xs = zscore(Xs);
[Xt, meanT, stdT] = zscore(Xt);

% For each iteration
converge = false;
while ~converge
    
    % Get a random orthogonal rotation matrix.
    R = getRandRot(N);
    if nargout > 2
        jR(:,:,end+1) = R; %#ok<*AGROW>
    end
    
    % Rotate the two datasets
    rXs = Xs * R;
    rXt = Xt * R;
    if nargout > 3
        jXs(:,:,end+1) = rXs;
    end
    
    % Do a quantile mapping of each column of rXs to rXt
    for k = 1:N
        rXs(:,k) = quantMap( rXs(:,k), rXt(:,k) );
    end
    
    % Do inverse rotation of the quantile mapping to get the new Xs
    Xs = rXs / R;
    
    % Get the squared energy distance
    D2 = estat( Xs, Xt );
    if nargout > 1
        E(end+1) = D2;
    end
    
    % Decrement
    nIter = nIter - 1;
    
    % Continue until the PDFs have converged or the maximum number of
    % iterations is reached.
    if D2 < tol
        converge = true;
    elseif nIter <= 0
        converge = true;
    end
end

% Restore the mean and standard deviation from the target
X = Xs .* stdT + meanT;

end