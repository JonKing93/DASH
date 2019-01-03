%% This is the basic for loop that will build each ensemble member 

% Preallocate the ensemble
M = NaN( nState, nEns );

% Get an index cell to use for each ensemble member
[ic, ix] = getFixedIndexCell( fixDex, fixed );

% For each ensemble member
for m = 1:nEns
    
    % For each ensemble variable, get the index of the current ensemble
    % member selection
    for d = 1:nDim
        if ~fixed(d)
            ic{d} = ensDex(m,d) + meanDex{d};
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
    
    % Add to the ensemble as a state vector
    M(:,m) = Mcurr(:);
end    