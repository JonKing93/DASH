function[Amean, Avar, Ye, R, update, calib] = jointENSRF( M, D, R, F, w, yloc, meanOnly, postflate )
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
    
    % Get the time steps with observations
    hasObs = ~isnan( D(d,:) );
    
    % Run the PSM
    [Ye(d,:), R(d,hasObs), update(d,hasObs)] = getPSMOutput( F{d}, Mpsm, R(d,hasObs), NaN, d  );
end

% Apply the postflation factor
M = inflateEnsemble( postflate, M );

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

% Preallocate the calibration ratio
calib = NaN( nObs, nTime );

% Calculate the Kalman numerator (this is unchanging for joint updates)
Knum = jointKalman( 'Knum', Mdev, Ydev, w );

% For each time step
for t = 1:nTime
    
    t
    % Slice variables
    Rt = R(:,t);
    Dt = D(:,t);
    
    % Update using obs that are not NaN
    update(:,t) = update(:,t) & ~isnan( Dt );
    obs = update(:,t);
    
    % Get the full kalman gain and kalman denominator
    [K, Kdenom] = jointKalman( 'K', Knum(:,obs), Ydev(obs,:), yloc(obs,obs), Rt(obs) ); %#ok<PFBNS>
    
    % Update the mean
    Amean(:,t) = Mmean + K * ( Dt(obs) - Ymean(obs) ); %#ok<PFBNS>
    K = [];   %#ok<NASGU>  (Free up memory)
    
    % Get the calibration ratio
    calib( obs, t ) = abs( Dt(obs) - Ymean(obs) ) ./ ( diag(Kdenom) );

    % If returning variance
    if ~meanOnly
    
        % Get the adjusted kalman gain
        Ka = jointKalman( 'Ka', Knum(:,obs), Kdenom, Rt(obs) );

        % Update the deviations and get the variance.
        Avar(:,t) = sum(   (Mdev - Ka * Ydev(obs,:)).^2, 2) ./ (nEns-1);
%         Avar(:,t) = var( Mdev - Ka * Ydev(obs,:), [], 2);
    end
end

end