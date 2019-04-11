function[] = buildVarEnsemble(fEns, var, varDex, nEns)
% buildVarEnsemble( fEns, var, varDex, nEns )

% Get a read-only matfile object for the gridded data
fGrid = matfile( var.file );

% Get the index and size of the ensemble dimensions
[ensSize, ensDex] = getVarSize( var, 'ensOnly', 'seq' );

% Get the total number of sequence elements
nSeq = prod( ensSize );

% Get N-dimensional subscripted sequence indices
seqDex = subdim( ensSize, (1:nSeq)' );

% Get the reference loading indices and the indices to keep
[refLoad, keep] = getLoadingIndices( var );

% For each ensemble member
for m = 1:nEns
    
    % For each sequence element
    for s = 1:nSeq
        
        % Initialize a specific set of sampling indices from the reference indices.
        load = refLoad;
        
        % Get the unique sampling indics for each ensemble dimension
        for dim = 1:numel(ensDex)
            d = ensDex(dim);
            load{d} = var.indices{d}(m) + var.seqDex{d}(seqDex(s,dim)) + refLoad{d};
        end
        
        % Load the data
        M = fGrid.gridData( load{:} );
        
        % Only keep the values associated with sampling indices.
        M = M( keep{:} );
        
        % Take the mean along any relevant dimensions
        M = takeDimMeans( M, var.takeMean, var.nanflag );
        
        % Add to the .ens file
        fEns.M( varDex, m ) = M(:);
    end
end

% Ensure that no rows are entirely NaN.
checkNaNRows( fEns, var, varDex );

end