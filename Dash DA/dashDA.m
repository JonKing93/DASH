function[A, Y] = dashDA( M, D, R, w, F, H )
%% Implements data assimilation using an ensemble square root filter with serial
% updates for individual observations. Time steps are assumed independent
% and processed in parallel.
%
% [A, Y] = dashDA( M, D, R, w, F, H )
% Performs data assimilation.
%
% ----- Inputs -----
%
% M: The model ensemble. (nState x nEns)
%
% D: The observations. (nObs x nTime)
%
% R: Observation uncertainty. NaN values will be determined via dynamic R
%    generation by the PSM. (nObs x nTime)
%    !!!!! Need to implement a more general R calculation
%
% w: Covariance localization weights. (nState x nObs)
%      !!! Could this be dynamic?
%
% F: An array of proxy system models of the "PSM" class. One model for each
%      observation. (nObs x 1)
%
% H: A cell of state variable indices needed to run the forward model for
%      each site. {nObs x 1}
%      !!! Could this be dynamic?
%
% ----- Outputs -----
%
% A: The mean and variance of the analysis ensemble. (nState x nTime x 2)
%
% Y: The model estimates used for each update. (nObs x nEns x nTime)

% Ensure the PSMs are allowed
if ~isa( F, 'PSM' )
    error('F must be of the the "PSM" class');
end

% Get some sizes
[nObs, nTime] = size(D);
[nState, nEns] = size(M);

% Preallocate the output
A = NaN( nState, nTime, 2 );

% Decompose the ensemble
[Mmean, Mdev] = decomposeEnsemble(M);

% Preallocate Ye if it is desired as output.
if nargout>1
    Y = NaN( nObs, nEns, nTime);
end

% Each time step is independent, process in parallel
for t = 1:nTime
    
    % Slice variables to minimize parallel overhead
    tD = D(:,t);
    tR = R(:,t);
    
    % Initialize the update for this time step
    Amean = Mmean;
    Adev = Mdev;
    
    % If recording Ye, preallocate all Ye for the current time step to
    % allow sliced output for minimal parallel overhead.
    if nargout>1
        Ycurr = NaN(nObs, nEns);
    end
    
    % For each observation that is not a NaN
    for d = 1:nObs
        if ~isnan(tD)
            
            % Get the state variables required to run the PSM.
            obSites = H{d};
        
            % Run the PSM
            Ye = F(d).runPSM( Amean(obSites)+Adev(obSites,:), d, obSites, t);
       
            % Decompose the model estimate
            [Ymean, Ydev] = decomposeEnsemble( Ye );
            
            % Somewhere around here should be the option for DA derived
            % values for R
            % !!!!! So implement it.
        
            % Get the Kalman gain and alpha
            [K, a] = kalmanENSRF( Adev, Ydev, tR(d), w(:,d));
        
            % Update
            Amean = Amean + K*( tD(d) - Ymean );
            Adev = Adev - (a * K * Ydev);
            
            % Record Y if desired as output
            if nargout>1
                Ycurr(d,:) = Ye;
            end     
        end
    end
    
    % Record the Y estimates for this time step.
    if nargout > 1
        Y(:,:,t) = Ye;
    end
    
    % Record the mean and variance of the analysis.
    Avar = var( Adev, 0, 2 );
    A(:,t,:) = [Amean, Avar];
end

end