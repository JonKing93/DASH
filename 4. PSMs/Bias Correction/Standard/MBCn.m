function[X] = MBCn( Xo, Xm, Xp, type, tol, nIter )
%% Performs the MBCn algorithm
% Applies bias correction to projected N-dimensional values by quantile
% delta mapping to observations and modeled historical values.

% Check that all X are matrices
if ~ismatrix(Xo) || ~ismatrix(Xm) || ~ismatrix(Xp)
    error('Xo, Xm, and Xp must all be matrices.');
end

% All must have the same number of variables
N = size(Xo,2);
if N ~= size(Xm,2) || N ~= size(Xp,2)
    error('Xo, Xm, and Xp must have the same number of columns.');
end

% Set nIter to infinite if not specified
if nargin < 4
    nIter = Inf;
end

% Do an initial QDM for each variable
X = NaN( size(Xp) );
for k = 1:N
    X(:,k) = qdm( Xo(:,k), Xm(:,k), Xp(:,k), type );
end

% Standardize the datasets. Use the same standardization for both
% historical modeled and projected variables. Use the Xm standardization to
% avoid inequally weighted variables in the convergence tests.
[Xo, meanO, stdO] = zscore(Xo);
[Xm, meanM, stdM] = zscore(Xm);
Xp = (Xp - meanM) ./ stdM;

% For each iteration
converge = false;
while ~converge
    
    % Get a random orthogonal rotation matrix
    R = getRandRot(N);
    
    % Rotate the datasets
    rXo = Xo * R;
    rXm = Xm * R;
    rXp = Xp * R;
    
    % For each rotated variable
    for k = 1:N
        
        % Do absolute qdm on the projected values
        rXp(:,k) = qdm( rXo(:,k), rXm(:,k), rXp(:,k), 'abs' );
        
        % Then get the quantile mapping from Xm to Xo
        rXm(:,k) = quantMap( rXm(:,k), rXo(:,k) );
    end
    
    % Do the inverse rotation. (For a random orthogonal rotation matrix,
    % the transpose is equal to the inverse)
    Xp = rXp * R';
    Xm = rXm * R';
    
    % Get the squared energy distance
    E = estat(Xm, Xo);
    
    % Decrement
    nIter = nIter - 1;
    
    % Continue until PDFs converge or maximum number of iterations
    if E < tol || nIter <= 0
        converge = true;
    end
end

% For each variable
for k = 1:N
    
    % Sort the variable from the original QDM
    X(:,k) = sort( X(:,k) );
    
    % Order the sorted variables according to the rank of each element in
    % the final transformed set of projected values
    [~,rankOrder] = sort( Xp );
    X(:,k) = X(rankOrder,k);
end

% Restore the standardization from the observations
X = X .* stdO + meanO;

end