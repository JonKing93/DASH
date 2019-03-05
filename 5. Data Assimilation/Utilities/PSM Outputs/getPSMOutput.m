function[Ye, R, update] = getPSMOutput( F, Mpsm, R, d, t )

% Get the ensemble size
nEns = size(Mpsm,2);

% Check if generating R values
getR = false;
if any(isnan(R(:)))
    getR = true;
end

% Attempt to run the PSM
try
    
    % Run with or without R calculation
    if getR
        [Ye, Rpsm] = F.runPSM( Mpsm, d, t );
    else
        Ye = F.runPSM( Mpsm, d, t );
    end
    
    % Check that Ye were valid
    checkPSMOutputs( Ye, nEns );
    
    % No errors were thrown, use the Ye to update the analysis
    update = true;
    
    % Set R values if dynamically generating
    if getR
        R = setRValues( R, Rpsm, d, t );
    end

% If the PSM failed...
catch ME
    
    % Notify the user
    psmFailureMessage(ME.message, d, t);
    
    % Create NaN Ye output
    Ye = NaN(1, nEns);
    
    % Do not use the PSM to update the analysis.
    update = false;
end

end