function[X] = MBCn( Xo, Xm, Xp, tol, nIter )
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

% Standardize the datasets
[Xo, meanXo, stdXo] = zscore(Xo);
Xm = zscore(Xm);
Xp = zscore(Xp);

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
    
    % Do the inverse rotation
    Xp = rXp / R;
    Xm = rXm / R;
    
    % Get the squared energy distance
    E = estat(Xm, Xo);
    
    % Decrement
    nIter = nIter - 1;
    
    % Continue until PDFs converge or maximum number of iterations
    if E < tol || nIter <= 0
        converge = true;
    end
end 

% Restore the mean and standard deviation from the observations
X = Xp .* stdXo + meanXo;

end