function[K, a] = serialKalman( Mdev, Ydev, w, yloc, R )
%% Gets the Kalman Gain and alpha for a Kalman Ensemble Square Root Filter
%
% [K, a] = kalmanENSRF( Mdev, ydev, r, w, 1 )
% Computes the kalman gain and alpha scaling factor for a serial update.
%
% [K, Ka] = kalmanENSRF( Mdev, Ydev, R, W, yloc )
% Computes the kalman gain and adjusted kalman gain for a joint update.
%
% ----- Inputs -----
%
% Mdev: Model deviations. (nState x nEns)
%
% ydev: Ye deviations for a single observation. (1 x nEns)
% Ydev: Ye deviations. (nObs x nEns)
%
% r: Uncertainty for a single observation. (1 x 1)
% R: Ye error variances. (nObs x 1)
%
% w: A covariance localization for a single observation. (nState x 1)
% W: Covariance localization for multiple observations. (nState x nObs)
%
% yloc: Localization weights for Ye error covariance. (nObs x nObs)
%
% ----- Outputs -----
%
% K: The kalman gain
%
% a: The alpha weight for the adjusted kalman gain for a serial update.
%
% Ka: The adjusted Kalman gain for a joint update.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Determine which parts of the Kalman Gain to calculate
[getKnum, getK, getKa] = kalmanOptions( w, yloc );

% Get the coefficient for an unbiased estimator
if getKnum || getK

    % Get the coefficient for an unbiased estimator
    nEns = size(Ydev,2);
    unbias = 1 / (nEns-1);
end

% Get the numerator (localized covariance of M with Ye)
Knum = w .* unbias * (Mdev * Ydev');

% Get the denominator. This is the uncertainty in the system. It is the Ye
% error covariance + observation uncertainty.
Kdenom = yloc .* unbias * (Ydev * Ydev') + R;

% Get the full Kalman gain
K = Knum / Kdenom;

% If serial, just get the alpha weight to save memory
if serial
    Ka = 1 / ( 1 + sqrt(R/Kdenom) );
    
% If joint, get the full adjusted Kalman Gain
else
    Ka = Knum * (sqrtm(Kdenom)^(-1))' * (sqrtm(Kdenom) + sqrtm(R))^(-1);
end

end

function[getKnum, getK, getKa] = kalmanOptions( w, yloc )

% By default, get everything. This is the setting for serial updates.
getKnum = true;
getK = true;
getKa = true;

% If neither w nor yloc are specified, this is a joint update that only
% needs the adjusted gain.
if isempty(w) && isempty(yloc)
    getKnum = false;
    getK = false;
    
% If only w is specified, this is a joint update that only needs the kalman
% numerator
elseif isempty(yloc)
    getK = false;
    getKa = false;
    
% If only yloc is specified, this is a joint update that needs the full
% Kalman gain and kalman denominator.
elseif isempty(w)
    getKnum = false;
    getKa = false;
end

end    