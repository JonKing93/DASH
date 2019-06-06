function[colnan] = buildOrderSeqEns( fEns, M, var, varDex, seqDex, loadNC, keep, nEns, nSeq, nEls )
%% Outer loop is sequence element. Inner loop is ensemble member

% Preallocate an array for whether ensemble members contain NaN values.
colnan = false( 1, nEns );

% Check whether we are writing full variables
full = false;
if size(M,1) == numel(varDex)
    full = true;
end

% Get the size of any pre-existing ensemble. And the locations at which to
% write in the final file.
nPrev = fEns.ensSize(1,2);
writeDex = nPrev + (1:nEns);

% For each sequence member
for s = 1:nSeq
    
    % Get the location of the sequence within the full variable
    seqLoc = (s-1)*nEls + (1:nEls)';

    % For each ensemble member
    for mc = 1:nEns
        mc
        % Don't bother loading values for ensemble members that already
        % contain NaN values.
        if ~colnan(mc)
            
            % Get the draw associated with the ensemble member. 
            draw = nPrev + mc;
        
            % Load the data
            sM = loadChunk( var, seqDex(s,:), draw, loadNC, keep );

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
        fEns.M(stateDex, writeDex) = M;
    end
end

% Get the write indices

% If writing the full variable, add to the .ens file
if full
    fEns.M( varDex, writeDex ) = M;
end

end