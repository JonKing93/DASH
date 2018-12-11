function[A] = fullDA( M, D, Dsite, H, R, loc)
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
nTime = size(D,2);
nState = size(M,1);

% Preallocate the output
A = NaN( nState, 2, nTime);

% Decompose into ensemble mean and deviations
[Mmean, Mdev] = decomposeEnsemble(M);

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
        
        % Get the positions in the state vector needed to run the forward
        % model.
        obDex = currObs(d);       
        obSite = Dsite{ obDex }; %#ok<PFBNS>
        
        % Run the forward model to get the model estimate
        Ye = H( Amean(obSite,:) + Adev(obSite,:) ); %#ok<PFBNS>
        
        % Decompose the model estimate. 
        [Ymean, Ydev, Yvar] = decomposeEnsemble(Ye);
        
        % Get the Kalman numerator
        Knum = kalmanNumerator( Adev, Ydev, loc);
        
        % Calculate the Kalman Gain
        [K, alpha] = kalmanENSRF( Yvar, tR(obDex), Knum);
        
        % Get the innovation vector for the means
        innov = tD(obDex) - Ymean;
        
        % Update
        [Amean, Adev] = updateA( Amean, K, innov, Adev, alpha, Ydev );        
    end
    
    % For now, just record the variance of the updated deviations
    Avar = var( Adev, 0, 2);
    
    % Save the updated mean and variance
    A(:,:,t) = [Amean, Avar];
    
end

end