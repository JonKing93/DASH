function[A] = dashDA( M, D, R, w, F, H )
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
nTime = size(D,2);
nState = size(M,1);

% Preallocate the output
A = NaN( nState, nTime, 2 );

% Decompose the ensemble
[Mmean, Mdev] = decomposeEnsemble(M);

% Each time step is independent, process in parallel
parfor t = 1:nTime
    
    % Slice variables to minimize parallel overhead
    tD = D(:,t);
    tR = R(:,t);
    
    % Initialize the update for this time step
    Amean = Mmean;
    Adev = Mdev;
    
    % Get the observations that are not NaN in this time step
    currObs = find( ~isnan(tD) );
    
    % For each observation
    for d = 1:numel(currObs)

        % Get the observation index and sampling indices
        obNum = currObs(d);
        obSite = H{ obNum }; %#ok<PFBNS>
        
        % Determine what to give the forward model
        % !!!!! Should implement anomaly options?
        Mpsm = Amean(obSite) + Adev(obSite,:);
        
        % Run the PSM
        [Ye] = F(obNum).runPSM( Mpsm, obNum, obSite, t); %#ok<PFBNS>
       
        % Decompose the model estimate
        [Ymean, Ydev] = decomposeEnsemble(Ye);
        
        % If the user-specified R is NaN, calculate from the variance of
        % the Ye
        if isnan( tR(obNum) )
            % !!!!!!!!!!!!! This should support a general method.
            tR(obNum) = var( Ye );
        end
        
        % Get the Kalman gain and alpha
        [K, a] = kalmanENSRF( Adev, Ydev, tR(obNum), w(obNum), currInflate); %#ok<PFBNS>
        
        % Update
        Amean = Amean + K*( tD(obNum) - Ymean );
        Adev = Adev - (a * K * Ydev);
    end
    
    % Record the mean and variance
    Avar = var( Adev, 0, 2 );
    A(:,t,:) = [Amean, Avar];
end

end