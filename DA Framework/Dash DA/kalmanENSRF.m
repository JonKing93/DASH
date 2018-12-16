function[K,a] = kalmanENSRF( Mdev, Ydev, R, w, inflate )

% Get the coefficient for an unbiased estimator
nEns = size(Mdev,2);
unbias = 1 / (nEns-1);

% Get the numerator
Knum = inflate * (unbias * Mdev * Ydev');

% Get variance of the deviations
Yvar = var(Ydev);

% Get the denominator
Kdenom = (inflate * Yvar) + R;

% Get the full gain
K = w .* (Knum / Kdenom);

% Get alpha
a = 1 / ( 1 + sqrt(R/Kdenom) );
end