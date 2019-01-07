function[nState, fixed] = processIndex( fixDex, seqDex )

% Preallocate
fixed = false(nDim,1);
nFixed = ones(nDim,1);
nSeq = ones(nDim,1);

% For each dimensino
for d = 1:nDim
    
    % A dimension cannot be both a state and ensemble variable
    if ~isnan(fixDex{d}) && ~isnan(seqDex{d})
        error('Dimension %s has both fixed and ensemble indices.', m.dimID{d} );
        
    % Note if a dimension is a state variable and get the number of indices
    elseif ~isnan(fixDex{d})
        fixed(d) = true;
        nFixed(d) = numel( fixDex{d} );
        
    % Get the sequence size for ensemble variables
    else
        nSeq(d) = numel( seqDex{d} );
    end
end

% Get the number of elements per dimension per state vector
nIndex = nFixed + (nSeq - 1);

% Get the size of the state vector
nState = prod(nIndex);

end