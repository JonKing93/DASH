function[A] = tardif18Vector_fixR(M, Ye, D, R, loc)
% This is a modification to the setup by Tardiff et al., 2018. It uses my
% vectorization of the Kalman updates to avoid serial processing.
% Consequently, the model estimates are never updated thus are not
% appended to the state vector, and the entire update is based on the
% initial variance of the estimates.
%
% This has the following properties:
%
% 1. Static ensemble of ANNUAL averages
% 2. Model estimates are not updated
% 3. Vectorized updates
% 4. Parallel? ...
% 5. Assumes a static localization
% 6. R is fixed

% M: The static model ensemble state vector. (nState x nEns)
%
% Ye: The estimates (nObs x nEns)
%
% D: The observations (nObs x nTime)
%
% R:
%
% loc:

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

% Calculate the Kalman Gain
Kdenom = Yvar + R;
K = Knum ./ Kdenom';

% Calculate the scaling factors for EnSRF
alpha = 1 ./ (1 + sqrt( R ./ Kdenom ) );

% Get the modified Kalman gain
K_ensrf = alpha' .* K;

% Get the innovation vector for the means
innov = D - Mmean;

% Each time step is independent, so parallelize
parfor t = 1:nTime
    
    % Get sliced variables to minimize parallel overhead
    tD = D(:,t);
    tInnov = innov(:,t);
       
    % Get the observations that exist in this time step
    currObs = ~isnan(tD);
    
    % Update the state vector mean
    Amean = Mmean + K(:,currObs) * tInnov(currObs); %#ok<PFBNS>
    
    % Update the deviations
    Adev = Mdev - K_ensrf(:,currObs) * Ydev(currObs,:); %#ok<PFBNS>
    
    % Get the variance of the deviations
    Avar = var( Adev, 0 , 2 );
    
    % Save the update with a sliced output variable
    A(:,:,t) = [Amean, Avar];
    
end

end