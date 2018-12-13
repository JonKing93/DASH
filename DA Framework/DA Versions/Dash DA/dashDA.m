function[A] = dashDA( M, D, R, w, inflate, F, H, meta )

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
    
    % Initialize the inflation factor
    currInflate = inflate;
    
    % For each observation
    for d = 1:numel(currObs)

        % Get the sampling indices
        obDex = currObs(d);
        obSite = H{ obDex }; %#ok<PFBNS>
        
        % Determine what to give the forward model
        if strcmpi( F.space, 'anomaly' ) %#ok<PFBNS>
            Mpsm = Adev(obSite,:);
        elseif strcmpi( F.space, 'full')
            Mpsm = Amean(obSite) + Adev(obSite,:);
        end
        
        % Run the DA
        Ye = F.runPSM( Mpsm, meta, obSite, t);
       
        % Decompose the model estimate
        [Ymean, Ydev] = decomposeEnsemble(Ye);
        
        % Get the Kalman gain and alpha
        [K, a] = kalmanENSRF( Adev, Ydev, tR(obDex), w(obDex), currInflate); %#ok<PFBNS>
        
        % Update
        Amean = Amean + K*( tD(obDex) - Ymean );
        Adev = Adev + (a * K * Ydev);
        
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