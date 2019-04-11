function[colnan] = buildOrderSeqEns( fEns, fGrid, M, var, varDex, seqDex, refLoad, keep, nSeq, nEns, nEls )
%% Outer loop is sequence element. Inner loop is ensemble member

% Preallocate an array to whether ensemble members contain NaN
% contains NaN values.
colnan = false( 1, nEns );

% Check whether we are writing full variables
full = false;
if size(M,1) == numel(varDex)
    full = true;
end

% For each sequence member
for s = 1:nSeq
    
    % Get the location of the sequence within the full variable
    seqLoc = (s-1)*nEls + (1:nEls)';

    % For each ensemble member
    for mc = 1:nEns
        
        % Don't bother loading values for ensemble members that already
        % contain NaN values.
        if ~colnan(mc)
        
            % Load the data
            sM = loadChunk( fGrid, var, seqDex(s,:), mc, refLoad, keep );

            % If there aren't any NaN values, save the values
            if ~any( isnan(sM) )

                % If writing the entire variable, write to the state indices
                % for this sequence
                if full
                    M(seqLoc,mc) = sM;

                % Otherwise, writing one sequence at a time
                else
                    M(:,mc) = sM;
                end

            % If there were NaN elements
            else
                % Mark the ensemble member as bad
                colnan(mc) = true;
            end
        end
    end
    
    % If writing single sequences, add to the .ens file at the indices for
    % this sequence within the entire state vector.
    if ~full
        stateDex = varDex( seqLoc );
        fEns.M(stateDex, :) = M;
    end
end

% If writing the full variable, add to the .ens file
if full
    fEns.M( varDex, : ) = M;
end

end