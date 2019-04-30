function[Amean, Avar, Ye, R, update] = jointENSRF( M, D, R, F, w, yloc, meanOnly )
%% Does data assimilation using the Ensemble square root method (ENSRF).
% Runs all observations jointly. Does not use serial updates.

% Get some sizes
[nObs, nTime] = size(D);
[nState, nEns] = size(M);

% Preallocate Ye and an array to track when the PSM should be used to
% update the analysis
Ye = NaN( nObs, nEns );
update = false(nObs, nTime);

% For each observation
for d = 1:nObs
    
    % Get the model values being passed
    Mpsm = M(F{d}.H, :);
    
    % Run the PSM
    [Ye(d,:), R(d,:), update(d,:)] = getPSMOutput( F{d}, Mpsm, R(d,:), NaN, d  );
end

% Decompose the ensemble
[Mmean, Mdev] = decomposeEnsemble(M);
clearvars M;

% Decompose the model estimates
[Ymean, Ydev] = decomposeEnsemble( Ye );

% Preallocate the output
Amean = NaN(nState, nTime);

Avar = [];
if ~meanOnly
    Avar = NaN(nState, nTime);
end

% Calculate the Kalman numerator (this is unchanging for joint updates)
Knum = jointKalman( 'Knum', Mdev, Ydev, w );

% For each time step
parfor t = 1:nTime
    
    % Update using obs that are not NaN
    update(:,t) = update(:,t) & ~isnan( D(:,t) );
    obs = update(:,t);
    
    % Get the full kalman gain and kalman denominator
    [K, Kdenom] = jointKalman( 'K', Knum(:,obs), Ydev(obs,:), yloc(obs,obs), R(obs,t) ); %#ok<PFBNS>
    
    % Update the mean
    Amean(:,t) = Mmean + K * ( D(obs,t) - Ymean(obs) ); %#ok<PFBNS>
    K = [];   %#ok<NASGU>  (Free up memory)

    % If returning variance
    if ~meanOnly
    
        % Get the adjusted kalman gain
        Ka = jointKalman( 'Ka', Knum(:,obs), Kdenom, R(obs,t) );

        % Update the deviations and get the variance
        Avar(:,t) = var(   Mdev - Ka * Ydev(obs,:),   0, 2 );
    end
end

end
