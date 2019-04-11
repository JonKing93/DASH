function[colnan] = buildOrderEnsSeq( fEns, fGrid, M, var, varDex, seqDex, refLoad, keep, nSeq, nEns, nEls )

% Preallocate array to track whether ensemble members contain NaN values.
colnan = false( 1, nEns );

% Check whether we are writing full ensemble members
full = false;
if size(M,1) == numel(varDex)
    full = true;
end

% For each ensemble member
for mc = 1:nEns
    
    % For each sequence
    for s = 1:nSeq
        
        % Get the location of the sequence within the full variable
        seqLoc = (s-1)*nEls + (1:nEls)';
        
        % Load the data
        sM = loadChunk( fGrid, var, seqDex(s,:), mc, refLoad, keep );
        
        % If there aren't any NaN values, save the values
        if ~any( isnan(sM) )
            
            % If writing the entire ensemble member, save to state indices
            if full
                M(seqLoc,1) = sM;
                
            % Otherwise, write directly to .ens file
            else
                stateDex = varDex( seqLoc );
                fEns.M( stateDex, mc ) = sM;
            end
            
        % If there were NaN elements
        else
            % Mark the ensemble member as bad
            colnan(mc) = true;
        end
    end
    
    % Write entire ensemble member to file if appropriate.
    if full
        fEns.M( varDex, mc ) = sM;
    end
end

end