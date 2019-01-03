%% This is the basic for loop that will build each ensemble member 

% Preallocate the ensemble
M = NaN( nState, nEns );

% Get an index cell to use for each ensemble member
[ic, ix] = getFixedIndexCell( fixDex, fixed );

% Get the sequence array
seqArray = buildSequenceArray( fixed, seqDex );

% Create a cell to hold the subscripts of each sequence
currSeq = cell( sum(~fixed), 1 );

% For each ensemble member
for m = 1:nEns
    
    % Preallocate the collection of all sequences
    Mseq = NaN( nFixed, nSeq );
    
    % For each sequence
    for s = 1:max(seqArray)
        
        % Get the index of the current sequence for each dimension
        currSeq = getCurrSequence( fixed, seqArray, s );
        
        % Get the load indices for each ensemble variable
        for d = 1:nDim
            if ~fixed
                ic{d} = ensDex(m,d) + seqDex{d}(currSeq(d)) + meanDex{d};
            end
        end
        
        % Do the initial load from the .mat file
        Mcurr = m.gridFile( ic{:} );
    
        % Restrict any fixed indices that were not equally spaced
        Mcurr = Mcurr( ix{:} );

        % Take the mean in any relevant dimension
        for d = 1:nDim
            if takeMean(d)
                Mcurr = mean( Mcurr, d, nanflag );
            end
        end
        
        % Add to the collection of sequences
        Mseq(:,s) = Mcurr(:);
    end
    
    % Add to the ensemble as a state vector
    M(:,m) = Mseq(:);
end    