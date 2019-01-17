function[M] = buildVarEnsemble(var, nEns, ic, ix)
%% Builds the ensemble for a single variable

% Get a read-only matfile
grid = matfile( var.file );

% Get the number of state elements per sequence, and the total number of
% sequence elements
[nState, nSeq] = countVarStateSeq( var );

% Preallocate the variable ensemble
M = NaN( nState*nSeq, nEns );

% For each ensemble member
for m = 1:nEns
    
    % Preallocate a full sequence
    seqM = NaN( nState*nSeq, 1 );
    
    % For each sequence element
    for s = 1:nSeq
        
        % Get the ensemble indices
        ic = getEnsLoadIndex( var, ic );
        
        % Load the data
        sM = grid.gridData( ic{:} );
        
        % Trim the data
        sM = sM( ix{:} );
        
        % Take the mean in appropriate dimensions
        sM = takeDimMeans(sM, var.takeMean);
        
        % Place as state vector in the full sequence
        seqM( (s-1)*nState+1:s*nState ) = sM(:);
    end
        
    % Save the full sequence in the ensemble
    M(:,m) = seqM;
end

end     