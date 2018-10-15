function[M] = ensrfSerialUpdate(M, D, R, H)
% This does EnSRF updates for a dynamic ensemble in serial. It is solely
% for speedtesting. For actual implementation, use the vectorized
% ensrfUpdate.m function.
%
% A = ensrensrf( M, D, R, H )

% Get some sizes
nEns = size(M,2);
nObs = length(D);

% Get the model means and deviations
Mmean = mean(M,2);
Mdev = M - Mmean;

% Get the observation estimates. Split into means and deviations.
Y = H * M;
Ymean = mean(Y,2);
Ydev = Y - Ymean;
Yvar = var(Y,0,2);

% Get the Kalman Gain numerators
unbias = 1 / (nEns - 1);
Knum = unbias * Mdev * Ydev';

% For each observation...
for k = 1:nObs
    
    % Get the innovation vector
    innov = D(k) - Ymean(k);
    
    % Get the Kalman Gain Denominator
    Kdenom = Yvar(k) + R(k);
    
    % Get the Kalman Gain
    % Knum = unbias * Adev * Ydev'
    K = Knum(:,k) ./ Kdenom;
    
    % Update the ensemble means
    Mmean = Mmean + K*innov;
    
    % Get the EnSRF matrix
    alpha = 1/(1+sqrt( R(k) / (Yvar(k)+R(k)) ) );
    K_ensrf = alpha * K;
    
    % Update the deviations
    Mdev = Mdev - K_ensrf * Ydev(k,:);
    
end

% Recover full field
M = Mmean + Mdev;

end
