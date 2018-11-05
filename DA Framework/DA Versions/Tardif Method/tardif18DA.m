function[A] = tardif18DA(M, Ye, D, R, loc)
% This is a seasonal updater for the NTREND experiment
% It strictly follows the setup by Tardiff et al., 2018
% It has the following properties
%
% 1. Static Ensemble of ANNUAL averages
% 2. Model Estimates are appended to the state vector
% 3. Serial updates with no vectorizing
% 4. Parallel time steps
% 5. Static localization

% M: The static model ensemble state vector. (nState x nEns)
%
% Ye: The estimates (nObs x nEns)
%
% D: The observations (nObs x nTime)
%
% R: (nObs x nTime)
%
% loc: The set of covariance localizations (nState x p)

% Get some sizes
nState = size(M,1);
nEns = size(M,2);
nTime = size(D,2);

% Preallocate the output
A = NaN( nState, 2, nTime );

% Begin by appending the model estimates to the model ensemble to create
% the static ensemble state vector.
M = [M;Ye];

% Decompose into ensemble mean and deviations
Mmean = mean(M,2);
Mdev = M - Mmean;

% Get the scaling factor for unbiased covariance calculations
unbias = 1 / (nEns-1);

% Each time step is treated as independent, process in parallel
parfor t = 1:nTime

    % Get sliced variables for D and R for this time step to minimize parallel overhead
    tD = D(:,t);
    tR = R(:,t);

    % Initialize the update for this time step
    Amean = Mmean;
    Adev = Mdev;
 
    % Get the observations present in this time step
    currObs = find( ~isnan(tD) );

    % For each observation
    for d = 1:numel(currObs)

        % Get the index of the observation
        obDex = currObs(d);
        yeDex = nState + obDex;

        % Get the model estimates and observation uncertainty
        Ydev = Adev(yeDex,:);
        Ymean = Amean(yeDex,:);
        Yvar = var( Ydev, 0, 2 );
        r = tR(obDex);

        % Calculate the Kalman Gain
        Knum = unbias * Adev * Ydev';
        Kdenom = Yvar + r;

        K = Knum / Kdenom;

        % Apply the covariance localization
        Kloc = loc .* K;

        % Get the innovation vector for the means
        innov = tD(obDex) - Ymean;

        % Update the state vector mean
        Amean = Amean + Kloc*innov;
  
        % Get the scaling factor for the EnSRF adjusted Kalman gain
        a = 1 ./ (1 + sqrt( r ./ (Kdenom) ) );

        % Update the state vector deviations
        Adev = Adev - (a * Kloc * Ydev);
        
    end
    
    % For now, just record the variance of the updated deviations
    Avar = var( Adev(1:nState,:), 0, 2);
    
    % Save the updated ensemble mean and the variance of deviations. Use a
    % sliced output variable to minimize parallel overhead.
    A(:,:,t) = [Amean(1:nState), Avar];
    
end

end