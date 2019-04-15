function[] = addWriteEnsemble( fEns, design, nNew )

% Get the variable indices
[varDex] = getVariableIndices( design.var );

% Get the current number of ensemble members
nPrev = fEns.ensSize(1,2);

% Flip the complete toggle
fEns.complete = false;

% Preallocate tshe new ensemble members
nState = max( varDex{end} );
fEns.M( 1:nState, nPrev + (1:nNew) ) = NaN;

% Track the new ensemble members that contain NaN elements
hasnan = false(1, nEns);

% Add to the ensemble for each variable
for v = 1:numel(design.var)
    nanCols = getVarEnsemble( fEns, design.var(v), varDex{v}, nNew );
    hasnan = hasnan & nanCols;
end

% If any columns contain NaN
if any(hasnan)
    
    % Get the indices of the bad ensemble members
    nanDex = find(hasnan);
    
    % Delete iteratively
    for k = 1:numel(nanDex)
        fEns.M(:, nPrev+nanDex(k)) = [];
    end
    
    % Report the number of ensemble members removed
    fprintf('Removed %.f of the new ensemble members for containing NaN elements.\n', numel(nanDex) );
end

% Record the size of the ensemble
ensSize = [nState, nPrev + (nNew - sum(hasnan))];

% Save the metadata
fEns.ensSize = ensSize;
fEns.design = design;

% Success! Set the "complete" toggle to true
fEns.complete = true;
end 