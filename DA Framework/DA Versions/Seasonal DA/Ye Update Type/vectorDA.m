function[A] = vectorDA(M, Ye, D, R, w)
% A modification using vectorized updates but for time-dependent R.
%
% M: Model Ensemble (nState x nEns)
%
% Ye: Model estimates (nObs x nEns)
%
% D: Observations (nObs x nTime)
%
% R: Observational Uncertainty (nObs x nTime)
%
% w: Covariance weights

% Get some sizes
nTime = size(D,2);
nState = size(M,1);

% Preallocate the output
A = NaN( nState, 2, nTime);

% Decompose M into ensemble mean and deviations
[Mmean, Mdev] = decomposeEnsemble(M);

% Also decompose the model estimates and get their variance
[Ymean, Ydev, Yvar] = decomposeEnsemble(Ye);

% Get the Kalman numerator
Knum = kalmanNumerator( Mdev, Ydev, w);

% Get the innovation vector for the means
innov = D - Ymean;

% Each time step is independent, so parallelize
parfor t = 1:nTime
    
    % Get sliced variables to minimize parallel overhead
    tD = D(:,t);
    tR = R(:,t);
    tInnov = innov(:,t);
    
    % Get the current observations
    currObs = ~isnan(tD);
    
    % Calculate the Kalman Gain
    [K, alpha] = kalmanENSRF( Yvar(currObs), tR(currObs), Knum(:,currObs) );  %#ok<*PFBNS>
    
    % Update
    [Amean, Adev] = updateA( Mmean, K, tInnov(currObs), Mdev, alpha, Ydev(currObs,:) );
    
    % Get the variance of the deviations
    Avar = var( Adev, 0 , 2 );
    
    % Save the update with a sliced output variable
    A(:,:,t) = [Amean, Avar];
    
end

end