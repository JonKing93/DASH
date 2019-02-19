function[Xs, R] = npdft( Xs, Xt, tol )
%
% Xs: Source data
%
% Xt: Target data
%
% tol: threshold to use for convergence
%
% ----- Outputs -----

% Check that Xs and Xt are matrices
if ~ismatrix(Xs) || ~ismatrix(Xt)
    error('Xs and Xt must be matrices.');
end

% Both must have the same number of variables
N = size(Xs,2);
if N ~= size(Xt,2)
    error('Xs and Xt must have the same number variables (columns).');
end

% Standardize both datasets
Xs = zscore(Xs);
[Xt, meanT, stdT] = zscore(Xt);

% For each iteration
converge = false;
while ~converge
    
    % Get a random orthogonal rotation matrix.
    R = getRandRot(N);
    
    % Rotate the two datasets
    rXs = Xs * R;
    rXt = Xt * R;
    
    % Do a quantile mapping of each column of rXs to rXt
    for k = 1:N
        rXs(:,k) = quantMap( rXs(:,k), rXt(:,k) );
    end
    
    % Do inverse rotation of the quantile mapping to get the new Xs
    Xs = rXs / R;
    
    % Get the squared energy distance
    D2 = estat( Xs, Xt );
    
    % Continue until the PDFs have converged
    if D2 < tol
        converge = true;
    end
end

% Restore the mean and standard deviation from the target
Xs = Xs .* stdT + meanT;

end