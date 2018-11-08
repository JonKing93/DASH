function[K,alpha] = kalmanENSRF( Yvar, R, Knum )

% Get the Kalman denominator
Kdenom = Yvar + R;

% Get the full gain matrix
K = Knum ./ Kdenom';

% Get the scaling factors for EnSRF
alpha = 1 ./ (1 + sqrt( R ./ Kdenom ) );

end