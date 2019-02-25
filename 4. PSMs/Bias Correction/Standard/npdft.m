function[X, E, jR, normT, normS] = npdft( Xt, Xs, tol, nIter )
%% Performs the N-pdft algorithm.
% Applies bias correction by equating the CDF of N-dimensional source data 
% with an N-dimensional target. Uses the energy distance statistic to
% monitor algorithm convergence.
%
% X = npdft( Xt, Xs, tol )
% Applies the N-pdft alogrithm until the energy distance of the source and
% target data falls below a threshold. Returns the bias-corrected output.
%
% X = npdft( Xt, Xs, tol, nIter )
% Sets a maximum number of allowed iterations.
%
% [X, E] = npdft( ... )
% Also returns the energy statistic for each iteration.
%
% [X, E, jR, normT, normS] = npdft( ... )
% Returns values to allow a static npdft.
%
% ----- Inputs -----
%
% Xt: Target data. (nSample x nVariables)
%
% Xs: Source data being bias corrected. (nSample x nVariables)
%
% tol: Energy distance threshold to use for convergence.
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
% normT: The standardization applied to the target
%
% normS: The standardization applied to the source.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

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

% Standardize both datasets
[Xs, meanS, stdS] = zscore(Xs);
[Xt, meanT, stdT] = zscore(Xt);

% Create / Preallocate static output
if nargout > 2
    normT = [meanT; stdT];
    normS = [meanS; stdS];
    jR = [];
end
E = [];

% For each iteration
converge = false;
j = 1;
while ~converge
    
    % Get a random orthogonal rotation matrix.
    R = getRandRot(N);
    
    % Rotate the two datasets
    rXs = Xs * R;
    rXt = Xt * R;
    
    % Record static output
    if nargout > 2
        jR(:,:,j) = R; %#ok<AGROW>
        j = j+1;
    end
    
    % Do a quantile mapping of each column of rXs to rXt
    for k = 1:N
        rXs(:,k) = quantMap( rXt(:,k), rXs(:,k) );
    end
    
    % Do inverse rotation of the quantile mapping to get the new Xs
    Xs = rXs * R';
    
    % Get the squared energy distance
    E(end+1) = estat( Xs, Xt ); %#ok<AGROW>
    
    % Decrement
    nIter = nIter - 1;
    
    % Continue until the PDFs have converged or the maximum number of
    % iterations is reached.
    if E(end) < tol || nIter <= 0
        converge = true;
    end
end

% Restore the mean and standard deviation from the target
X = Xs .* stdT + meanT;

end