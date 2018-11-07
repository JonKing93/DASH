function[A] = seasDA_dynH( M, D, Dsite, H, R, loc)
% This is a script that does seasonal updates and reruns the output using a
% forward model.
%
% 1. Can call multiple values from the state vector.
%
% 2. Uses a dynamic R
%
%
% H: Function call to a forward model.

% Get some sizes
nEns = size(M,2);
nTime = size(D,2);
nState = size(M,1);

% Preallocate the output
A = NaN( nState, 2, nTime);

% Decompose into ensemble mean and deviations
Mmean = mean(M,2);
Mdev = M - Mmean;

% Get the scaling factor for unbiased covariance calculations
unbias = 1 / (nEns - 1);

% Each time step is independent, process in parallel
parfor t = 1:nTime
    
    % Get sliced variables for D and R for this time step to minimize
    % parallel overhead
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
        
        % Get the position of the observation in the state vector.
        obSite = Dsite{ obDex };
        
        % Run the forward model to get the model estimate
        Ye = H( Amean(obSite,:) + Adev(obSite,:) );
        
        % Decompose the model estimate. Also get observation uncertainty
        Ymean = mean(Ye,2);
        Ydev = Ye - Ymean;
        Yvar = var( Ydev, 0, 2 );
        r = tR(obDex);
        
        % Calculate the Kalman Gain
        Knum = unbias * Adev * Ydev';
        Kdenom = Yvar + r;
        
        K = Knum / Kdenom;
        
        % Apply te covariance localization
        Kloc = loc .* K;
        
        % Get the innovation vector for the means
        innov = tD(obDex) - Ymean;
        
        % Update the state vector mean
        Amean = Amean + (Kloc * innov);
        
        % Get the scaling factor for the adjusted gain
        a = 1 ./ (1 + sqrt(r ./ Kdenom) );
        
        % Update the deviations
        Adev = Adev - (a * Kloc * Ydev);
        
    end
    
    % For now, just record the variance of the updated deviations
    Avar = var( Adev, 0, 2);
    
    % Save the updated mean and variance
    A(:,:,t) = [Amean, Avar];
    
end

end