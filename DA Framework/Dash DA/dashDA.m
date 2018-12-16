function[A] = dashDA( M, D, R, w, inflate, F, H, meta )
%
% A = dashDA( M, D, R, w, inflate, F, H, meta )
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
% inflate: A scalar inflation factor
%
% F: A forward model of the "PSM" class
%   !!! Eventually, this should be an array of PSMs
%
% H: A cell of state variable indices needed to run the forward model for
%      each site. {nObs x 1}
%      !!! Could this be dynamic?
%
% meta: Metadata required to run PSMs. Please see individual PSMs for
%      metadata requirements.
%
% ----- Outputs -----
%
% A: The output analysis.

% Get some sizes
nTime = size(D,2);
nState = size(M,1);

% Preallocate the output
A = NaN( nState, nTime, 2 );

% Decompose the ensemble
[Mmean, Mdev] = decomposeEnsemble(M);

% Each time step is independent, process in parallel
for t = 1:nTime
    
    % Slice variables to minimize parallel overhead
    tD = D(:,t);
    tR = R(:,t);
    
    % Initialize the update for this time step
    Amean = Mmean;
    Adev = Mdev;
    
    % Get the observations that are not NaN in this time step
    currObs = find( ~isnan(tD) );
    
    % Initialize the inflation factor
    currInflate = inflate;
    
    % For each observation
    for d = 1:numel(currObs)

        % Get the sampling indices
        obDex = currObs(d);
        obSite = H{ obDex }; %#ok<PFBNS>
        
        % Determine what to give the forward model
        % !!!!! Should implement anomaly options?
        Mpsm = Amean(obSite) + Adev(obSite,:);
        
        % Run the PSM
        [Ye] = F.runPSM( Mpsm, meta, obDex, obSite, t);
       
        % Decompose the model estimate
        [Ymean, Ydev] = decomposeEnsemble(Ye);
        
        % If the user-specified R is NaN, calculate from the variance of
        % the Ye
        if isnan( tR(obDex) )
            % !!!!!!!!!!!!! This should support a general method.
            tR(obDex) = var( Ye );
        end
        
        % Get the Kalman gain and alpha
        [K, a] = kalmanENSRF( Adev, Ydev, tR(obDex), w(obDex), currInflate); %#ok<PFBNS>
        
        % Update
        Amean = Amean + K*( tD(obDex) - Ymean );
        Adev = Adev - (a * K * Ydev);
        
        % Only inflate covariance in the first time step
        if d == 1
            currInflate = 1;
        end
    end
    
    % Record the mean and variance
    Avar = var( Adev, 0, 2 );
    A(:,t,:) = [Amean, Avar];
end

end