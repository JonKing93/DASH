function[] = writeEnsemble( fEns, design, nEns )

% Get the variable indices within the ensemble
[varDex] = getVarIndices( design.var );

% Initialize an empty ensemble in the matfile
fEns.M = [];

% Initialize a toggle to mark if the build was successful
fEns.complete = false;

% Preallocate the ensemble within the matfile
nState = max( varDex{end} );
fEns.M(1:nState, 1:nEns) = NaN;

% Track the ensemble members that contain NaN elements
hasnan = false( 1, nEns );

% Build the ensemble for each variable and mark any NaN ensemble members
for v = 1:numel( design.var )
    nanCols = getVarEnsemble( fEns, design.var(v), varDex{v}, nEns );
    hasnan = hasnan & nanCols;
end

% If every column contains a NaN, the ensemble is invalid
if all(hasnan)
    
    % Delete the .ens file
    delete(fEns.Properties.Source);
    
    % Throw error
    error('Every ensemble member contained NaN elements.\n');
end

% If any columns contain NaN
if any(hasnan)
    
    % Get the indices of the bad ensemble members
    nanDex = find( hasnan );
    
    % These are not guaranteed to be evenly spaced. Delete them iteratively
    % from the .ens file
    for k = 1:numel(nanDex)
        fEns.M(:, nanDex(k)) = [];
    end
    
    % Report the number of ensemble members removed.
    fprintf('Removed %.f ensemble members that contained NaN elements.\n', numel(nanDex));
end

% Record the size of the ensemble
ensSize = [nState, nEns - sum(hasnan)];

% Save all the metadata
fEns.ensSize = ensSize;
fEns.design = design;

% Success! Set the "complete" toggle to true
fEns.complete = true;
end