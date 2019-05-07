function[X, E, converged, R] = npdft( Xt, Xs, tol, nIter )
%% Performs the N-pdft algorithm for bias-correction.
% Maps the CDF of N-dimensional source dataset to the CDF of an
% N-dimensional target. Uses the energy distance statistic to monitor
% algorithm convergence.
%
% [X, E] = npdft( Xt, Xs, tol )
% Applies the N-pdft alogrithm until the energy distance of the source and
% target data falls below a threshold. Returns the bias-corrected source
% data, and the energy distance for each iteration.
%
% [X, E, conv] = npdft( Xt, Xs, tol, nIter )
% Sets a maximum number of allowed iterations. Also returns a logical
% indicating whether the algorithm converged to values below the energy
% distance threshold.
%
% [X, E, conv, R] = npdft( ... )
% Returns the rotation matrices used for each iteration.
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
% X: The bias corrected source data. (nSample x nVariable)
%
% E: The energy statistic for each rotation. (nIter x 1)
%
% R: The rotation matrix used for each iteration. (nVar x nVar x nIter)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
%
% ----- References -----
% Pitié F, Kokaram AC, Dahyot R (2007) Automated colour grading using
% colour distribution transfer. Comput Vis Image Underst 107(1):123–137.
% doi: 10.1016/j.cviu.2006.11.011

% Set the number of iterations to infinite if unspecified
if ~exist( nIter, 'var')
    nIter = Inf;
end

% Error check. Preallocate output. Get a marker for variable output
[E, R, saveR] = setup( Xt, Xs, tol, nIter, nargout );

% Standardize both datasets. Record the mean and standard deviation of the target.
Xs = zscore(Xs);
[Xt, meanT, stdT] = zscore(Xt);

% Set the convergence marker to false. Also get an increment to count the
% number of iterations.
converged = false;
j = 1;

% For each iteration...
while ~converged
    
    % Get a random orthogonal rotation matrix.
    R = getRandRot(N);
    
    % Rotate the two datasets
    rXs = Xs * R;
    rXt = Xt * R;
    
    % Save the rotation matrix if desired as output
    if saveR
        R(:,:,j) = R;
    end
    
    % Use quantile mapping to map each column of the rotated source data
    % to each column of rotated target data.
    for k = 1:N
        rXs(:,k) = quantMap( rXt(:,k), rXs(:,k) );
    end
    
    % Do inverse rotation of the mapping to get the updated source data
    Xs = rXs * R';
    
    % Calculate the energy distance between the target and updated source data
    E(j) = estat( Xs, Xt );
    
    % If the datasets have converged
    if E(j) < tol
        
        % Set the convergence marker to true.
        converged = true;
        
        % Remove any unused iterations from the output
        E = E(1:j);
        if saveR
            R = R(:,:,1:j);
        end
    end
    
    % Stop iterating for convergence or maximum number of iterations.
    if converged || j==nIter
        break;
    end
    
    % Increment the iteration counter
    j = j+1;
end

% Restore the mean and standard deviation from the target dataset
X = Xs .* stdT + meanT;

end

function[E, R, saveR] = setup( Xt, Xs, tol, nIter, nOut )

% Check that Xs and Xt are matric
if ~ismatrix(Xs) || ~ismatrix(Xt)
    error('Xs and Xt must be matrices.');
end

% Both must have the same number of variables
N = size(Xs,2);
if N ~= size(Xt,2)
    error('Xs and Xt must have the same number variables (columns).');
end

% Need more than 1 sample
if size(Xs,1) == 1 || size(Xt,1) == 1
    error('Both Xs and Xt must have more than 1 row.');
end

% Set nIter to infinite if not specified
if ~isscalar(nIter) || nIter<1 || (mod(nIter,1)~=0 && ~isinf(nIter) )
    error('nIter must be a positive scalar integer.');
end

% Error check tol
if ~isscalar(tol) || tol<0
    error('tol must be a scalar that is greater than 0.');
end

% Check whether to save R
saveR = false;
if nOut > 3
    saveR = true;
end

% Intialize the energy statistic and R
E = [];
R = [];

% Preallocate E (and R) if the number of iterations is known.
if ~isinf(nIter)
    E = NaN( nIter, 1 );
    if saveR
        R = NaN( N, N, nIter );
    end
end

end