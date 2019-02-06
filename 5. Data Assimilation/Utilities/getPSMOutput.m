function[Ye, update] = getPSMOutput( F, Mpsm, d, t, nEns )

% Attempt to run the PSM
try
    Ye = F.runPSM( Mpsm, d, t );
    
    % Also check that the outputs were valid
    checkYe( Ye, nEns );
    
    % No errors were thrown, so use to update
    update = true;
    
    
% If an error was thrown, notify the user
catch ME
    fprintf(['PSM %0.f failed to run in time step %0.f with the error message: \n', ...
        ME.message, '\n', ...
        'Dash will not use observation %0.f to update the analysis in time step %0.f.\n\n'], ...
        d, t, d, t );
    
    % Block the PSM from updating the analysis
    update = false;
end

end