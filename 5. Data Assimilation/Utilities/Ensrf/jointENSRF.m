function[Amean, Avar, Ye] = tiJointENSRF( M, D, R, F, w, yloc )
%% Does data assimilation using the Ensemble square root method (ENSRF).
% Runs all observations jointly. Does not use serial updates.

% Get some sizes
[nObs, nTime] = size(D);
[nState, nEns] = size(M);

% Preallocate Ye and a check for PSM success
Ye = NaN( nObs, nEns );
update = false(nObs, 1);

% For each observation
for d = 1:nObs
    
    % Get the model values being passed
    Mpsm = M(F{d}.H, :);
    
    % Run the PSM
    [Ye(d,:), R(d), update(d)] = getPSMOutput( F{d}, Mpsm, R(d), d, NaN  );
end

% Decompose the ensemble
[Mmean, Mdev] = decomposeEnsemble(M);
clearvars M;

% Decompose the model estimates
[Ymean, Ydev] = decomposeEnsemble( Ye );

% Preallocate the output
Amean = NaN(nState, nTime);
Avar = NaN(nState, nTime);

% Do the update in each time step
for t = 1:nTime
    
    % Slice variables
    tD = D(:,t);
    tR = R(:,t);
    
    % Only use obs that are not NaN, have an R value, and successfully ran
    % the PSM.
    obs = ~isnan(tD) & ~isnan(tR) & update;
    
    % Calculate Kalman gain and adjusted gain.
    % (Must do this each time step to account for variable D and changing
    % R). However, we can precalculate the numerator.
    [K, Ka] = kalmanENSRF( Mdev, Ydev(obs,:), tR(obs), w(:,obs), yloc(obs,obs) );
    
    % Update
    Amean(:,t) = Mmean + K * ( tD(obs) - Ymean(obs) );
    Avar(:,t) = var(   Mdev - Ka * Ydev(obs,:),   0, 2 );
end

end
