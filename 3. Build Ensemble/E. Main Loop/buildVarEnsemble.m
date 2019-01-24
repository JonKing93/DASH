function[M] = buildVarEnsemble(var, nEns, iLoad, iTrim)
%% Builds the ensemble for a single variable

% Get a read-only matfile
grid = matfile( var.file );

% Get the number of state elements per sequence, and the total number of
% sequence elements
[nState, nSeq] = countVarStateSeq( var );

% Subscript sequence elements to all dimensions
[allSeq, siz] = getAllCombIndex( var.seqDex(~var.isState) );
subSeq = subdim( siz, allSeq );

% Preallocate the variable ensemble
M = NaN( nState*nSeq, nEns );

% For each ensemble member
for m = 1:nEns
    
    % Preallocate a full sequence
    seqM = NaN( nState*nSeq, 1 );
    
    % For each sequence element
    for s = 1:nSeq
        
        % Get the index cell
        ic = getEnsLoadIndex( var, iLoad, subSeq(s,:), m);
        
        % Load the data
        sM = grid.gridData( ic{:} );
        
        % Trim the data
        sM = sM( iTrim{:} );
        
        % Take the mean in appropriate dimensions
        sM = takeDimMeans(sM, var.takeMean, var.nanflag);
        
        % Place as state vector in the full sequence
        seqM( (s-1)*nState+1:s*nState ) = sM(:);
    end
        
    % Save the full sequence in the ensemble
    M(:,m) = seqM;
end

end     