function[A] = tardif18Vector_dynR(M, Ye, D, R, loc)
% A modification using vectorized updates but for time-dependent R.

% Get some sizes
nEns = size(M,2);
nTime = size(D,2);
nState = size(M,1);

% Preallocate the output
A = NaN( nState, 2, nTime);

% Decompose into ensemble mean and deviations
Mmean = mean(M,2);
Mdev = M - Mmean;

% Also break apart the model estimates into ensemble mean and deviations.
Ymean = mean(Ye,2);
Ydev = Y - Ymean;
Yvar = var(Y,0,2);

% Get the scaling factor for unbiased covariance calculations
unbias = 1 / (nEns - 1);

% Get the Kalman numerator
Knum = unbias * Mdev * Ydev';
Knum = loc .* Knum;

% Get the innovation vector for the means
innov = D - Mmean;

% Each time step is independent, so parallelize
parfor t = 1:nTime
    
    % Get sliced variables to minimize parallel overhead
    tD = D(:,t);
    tR = R(:,t);
    tInnov = innov(:,t);
    
    % Get the current observations
    currObs = ~isnan(tD);
    
    % Calculate the Kalman Gain
    Kdenom = Yvar(currObs) + tR(currObs); %#ok<PFBNS>
    K = Knum(:,currObs) ./ Kdenom'; %#ok<PFBNS>

    % Calculate the scaling factors for EnSRF
    alpha = 1 ./ (1 + sqrt( tR(currObs) ./ Kdenom(currObs) ) );

    % Get the modified Kalman gain
    K_ensrf = alpha' .* K;
    
    % Update the state vector mean
    Amean = Mmean + K * tInnov(currObs);
    
    % Update the deviations
    Adev = Mdev - K_ensrf * Ydev(currObs,:);  %#ok<PFBNS>
    
    % Get the variance of the deviations
    Avar = var( Adev, 0 , 2 );
    
    % Save the update with a sliced output variable
    A(:,:,t) = [Amean, Avar];
    
end

end