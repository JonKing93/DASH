function[M, full] = preallocateVarEnsemble( nState, nSeq, nEns, varName )

% Attempt to preallocate the entire variable across all ensemble members.
try
    M = NaN( nState, nEns );
    
    % If successful, write the full variable to the .mat file
    full = true;
    return;
    
% Try again if this fails.
catch
end

% Attempt to preallocate an entire sequence across all ensemble members
try
    M = NaN( nState/nSeq, nEns );
    
    % If successful, flip toggle and exit
    full = true;
    return;
    
% Try again if this fails
catch
end

% Attempt to preallocate an entire ensemble member
try
    M = NaN( nState, 1 );
    
    % If successful, flip toggle and exit
    full = false;
    return;
    
% Try again if this fails
catch
end

% Finally, attempt to preallocate one sequence element of one ensemble member
try
    M = NaN( nState/nSeq, 1 );
    full = false;
    
% If this fails, the ensemble cannot be loaded. Throw an error.
catch
    error(['A single sequence element of variable %s is too large (%.f elements) to load into memory,', ...
        newline, 'so the ensemble cannot be built. Use a smaller state vector for variable %s.'], ...
        varName, nState / nSeq, varName);
end

end