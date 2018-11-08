function[Knum] = kalmanNumerator( Mdev, Ydev, loc)

% Get the scaling factor for unbiased covariance calculations
nEns = size(Mdev,2);
unbias = 1 / (nEns-1);

% Calculate the Kalman numerator
Knum = loc .* (unbias * Mdev * Ydev');

end