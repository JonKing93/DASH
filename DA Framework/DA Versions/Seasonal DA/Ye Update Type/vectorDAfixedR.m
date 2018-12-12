function[A] = vectorDAfixedR(M, Ye, D, R, w)
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
nTime = size(D,2);
nState = size(M,1);

% Preallocate the output
A = NaN( nState, 2, nTime);

% Decompose the model ensemble into mean and deviations
[Mmean, Mdev] = decomposeEnsemble(M);

% Also break apart the model estimates into ensemble mean and deviations.
[Ymean, Ydev, Yvar] = decomposeEnsemble(Ye);

% Get the Kalman numerator
Knum = kalmanNumerator(Mdev, Ydev, w);

% Get the innovation vector for the means
innov = D - Ymean;

% Calculate the Kalman Gain
[K, alpha] = kalmanENSRF( Yvar, R, Knum);

% Each time step is independent, so parallelize
parfor t = 1:nTime
    
    % Get sliced variables to minimize parallel overhead
    tD = D(:,t);
    tInnov = innov(:,t);
       
    % Get the observations that exist in this time step
    currObs = ~isnan(tD);
    
    % Update the state vector mean
    [Amean, Adev] = updateA(Mmean, K(:,currObs), tInnov(currObs), Mdev, alpha, Ydev(currObs,:) ); %#ok<PFBNS>
    
    % Get the variance of the deviations
    Avar = var( Adev, 0 , 2 );
    
    % Save the update with a sliced output variable
    A(:,:,t) = [Amean, Avar];
    
end

end