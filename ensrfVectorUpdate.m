function[M] = ensrfVectorUpdate(M, D, R, H)
% A vectorized version of dynamic EnSRF serial updates
%
% ensrf( M, Y, D, R )
%
%

% Get the model means and deviations
Mmean = mean(M,2);
Mdev = M - Mmean;

% Get the observation estimates. Split into means and deviations.
Y = H * M;
Ymean = mean(Y,2);
Ydev = Y - Ymean;
Yvar = var(Y,0,2);

% Get the Kalman Gain numerator
unbias = 1 / (nEns-1);
Knum = unbias * Mdev * Ydev';

% Get the Kalman Gain denominator
Kdenom = Yvar + R;

% Get the Kalman Gain
K = Knum ./ Kdenom';

% Get the innovation vector
innov = D - Ymean;

% Update the means
Mmean = Mmean + K*innov;

% Calculate the scaling factors for the ensemble square root gain
alpha = 1 ./ (1 + sqrt( R./(Yvar + R) ) );

% Get the ensemble square root gain
K_ensrf = alpha' .* K;

% Update the deviations
Mdev = Mdev - K_ensrf * Ydev;

% Recover full field
M = Mmean + Mdev;

end
