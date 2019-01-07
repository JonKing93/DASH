function[M] = buildEnsemble( nEns, design )
%% This is the basic loop that will build the ensemble

% Get the state variable indices for each variable
[varCell, nEls] = getVariableIndices( design );
nState = sum(nEls);
nVar = numel( design.varDesign );

% Preallocate the ensemble
M = NaN( nState, nEns ); 

% For each variable
for v = 1:nVar

    % Get the variable design
    var = design.varDesign(v);
    nDim = numel( var.dimID );
    
    % Get a read-only matfile
    grid = matfile( var.file );

    % Get an index cell to use for loading fixed indices
    [ic, ix] = getFixedIndexCell( var.fixDex, var.fixed );

    % Get the sequence array
    seqArray = buildSequenceArray( var.fixed, var.seqDex );
    
    % Preallocate a collection of all sequences
    Mseq = NaN( nFixed, numel(seqArray) );
    
    % For each ensemble member
    for m = 1:nEns
    
        % For each sequence
        for s = 1:max(seqArray)
        
            % Get the index of the current sequence for each dimension
            currSeq = getCurrSequence( var.fixed, seqArray, s );
        
            % Get the load indices for each ensemble variable
            for d = 1:nDim
                if ~var.fixed
                    ic{d} = var.ensDex(m,d) + var.seqDex{d}(currSeq(d)) + var.meanDex{d};
                end
            end
        
            % Do the initial load from the .mat file
            Mcurr = grid.gridData( ic{:} );
    
            % Restrict any fixed indices that were not equally spaced
            Mcurr = Mcurr( ix{:} );

            % Take the mean in any relevant dimension
            for d = 1:nDim
                if var.takeMean(d)
                    Mcurr = mean( Mcurr, d, var.nanflag{d} );
                end
            end
        
            % Add to the collection of sequences
            Mseq(:,s) = Mcurr(:);
        end

        % Add the set of sequences to the ensemble as a state vector in the
        % indices for the variable.
        M( varCell{v}, m ) = Mseq(:);
    end
end

end