function[M] = buildEnsemble( nEns, design )
%% This is the basic loop that will build the ensemble

% Get the indices of each variable in the state vector.
[varIndex] = getVariableIndices( design );
nState = max( varIndex{end} );
nVar = numel( design.var );

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
    
    % Get the metadata for fixed indices
    
    
    
    
    
    
    
    
    
    

    % Select ensemble members
    ensMember = drawEnsembleMembers( nEns, var.ensDex, overlap );
    
    % Get the sequence array
    seqArray = buildSequenceArray( var.fixed, var.seqDex );
    
    % Preallocate a full sequence.
    Mseq = NaN( nFixed, numel(seqArray) );
    
    % For each ensemble member
    for m = 1:nEns
        
        % Set some switches
        runLoop = 2000;
        redraw = -1;
    
        % Try ensemble members until one is found without NaN elements.
        while redraw
            
            % Time out error
            if ~runLoop
                error('Could not select non-NaN state vector in the allotted time.');
            end
            runLoop = runLoop-1;
            
            % If there was a NaN element
            if redraw>0
                % Draw a new ensemble member
                ensMember(m,:) = drawEnsembleMembers( 1, var.ensDex, overlap, [ensMember(1:m-1,:); ensMember(m+1:end,:)] );
            end
            
            % For each sequence
            for s = 1:max(seqArray)
            
                % Get the index of the current sequence for each dimension
                currSeq = getCurrSequence( var.fixed, seqArray, s );
            
                % Get the load indices for each ensemble variable
                for d = 1:nDim
                    if ~var.fixed
                        ic{d} = ensMember(m,d) + var.seqDex{d}(currSeq(d)) + var.meanDex{d};
                    end
                end

                % Do the initial load from the .mat file
                Mcurr = grid.gridData( ic{:} );

                % Restrict any fixed indices that were not equally spaced
                Mcurr = Mcurr( ix{:} );

                % Take any means
                for d = 1:nDim
                    if var.takeMean(d)
                        Mcurr = mean( Mcurr, d, var.nanflag{d} );
                    end
                end
                
                % Check for unallowed values
                if any( isnan(Mcurr(:)) | iscomplex(Mcurr(:)) | isinf(Mcurr(:)) )
                    redraw = 1;
                    break;
                end

                % Add to the collection of sequences
                Mseq(:,s) = Mcurr(:);
            end 
        end

        % Add the full sequence to the ensemble as a state vector in the
        % indices for the variable.
        M( varCell{v}, m ) = Mseq(:);
    end
end

end