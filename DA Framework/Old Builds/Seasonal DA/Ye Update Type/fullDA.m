function[A] = fullDA( M, meta, D, R, H, F, w)
% This is a script that does seasonal updates and reruns the output using a
% forward model.
%
%
%
%
% M: The model ensemble. (nState x nEns)
%
% meta: A structure with metadata for the PSM. Must contain two fields:
%    coords: An array of coordinates for each state variable. (nState x nAxes)
%    time: A vector with the date of each observation. (nTime x 1)
%
% D: The observations. (nObs x nTime)
%
% R: Observation uncertainty (nObs x nTime)
%    !!!!!!!!!!!!! We should implement dynamic R
%
% H: A cell with the indices needed to run the PSM at each time step.
%      time step. Each site may use multiple state variables to run the
%      forward model. {nSite x 1}
%      !!!!!!!!!!!!! We should implement dynamic H
%
% F: A forward model. Must inherit the superclass PSM.m
%
% w: Covariance weights

% Check that F is a PSM
if ~isa(F, 'PSM')
    error('F must be a PSM class.');
end

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
        obSite = H{ obDex }; %#ok<PFBNS>
        
        % Run the forward model to get the model estimate
        Ye = F.runPSM( Amean(obSite,:) + Adev(obSite,:), meta.coord(obSite,:), meta.time(t) ); %#ok<PFBNS>
        
        % Decompose the model estimate. 
        [Ymean, Ydev, Yvar] = decomposeEnsemble(Ye);
        
        % Get the Kalman numerator
        Knum = kalmanNumerator( Adev, Ydev, w);
        
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