function[A] = serialENSRF(M, Ye, D, R, w)
%% Does ENSRF with the Potter method

% Get sizes
[nState, nEns] = size(M,1);
[nObs, nTime] = size(D);

% Decompose the ensemble to preset the output
[Amean, Adev] = decomposeEnsemble(M);

% Also decompose the Ye
{Ymean, Ydev] = decomposeEnsemble(Ye);

% Get the unbiased estimator coefficient
unbias = 1 / (nEns - 1);

% For each observation
for s = 1:nObs
    
    % Calculate the Kalman Gain
    Knum = unbias * Adev * Ydev(s,:)';
    Kdenom = unbias * (Ydev * Ydev') + R(s);
    K = Knum / Kdenom;
    
    % Update the Mean
    Amean = Amean + K*( D(s) - Ymean );
    
    % Calculate alpha
    alpha = (1 + sqrt( R(s) / Kdenom ) )^(-1);
    
    % Update the deviations
    Adev = Adev
    
    
    