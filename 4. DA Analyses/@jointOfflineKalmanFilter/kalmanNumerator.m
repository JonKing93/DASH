function[Knum] = kalmanNumerator( Mdev, Ydev, w )
% Computes the numerator of the Kalman Gain, which is the covariance of the
% model ensemble with the proxy estimates.
%
% Mdev: nState x nEns
%
% Ydev: nSite x nEns
unbias = 1 / (size(Mdev,2)-1);
Knum = unbias .* w .* (Mdev * Ydev');
end