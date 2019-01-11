%% This is the coupler for ensemble indices

% For each ensemble dimension
for d = 1:nDim
    if ~isState(d)
        
        % Get the metadata for X in the ensemble indices
        currX = xMeta.(dimID{d})(x.ensDex{d});
        
        % Get the metadata from Y for the dimension
        currY = yMeta.(dimID{d});
        
        % Ensure that the X metadata is neither NaN nor repeated
        if any(isnan(currX)) || numel(unique(currX))~=numel(currX)
            error('The metadata for the template variable contains NaN or repeated values in dimension %s.', dimID{d});
        end
        
         % If unspecified, match the sequence indices in Y to X
        if isempty(seqDex{d})
            seqDex{d} = X.seqDex{d};
        end
        
        % If unspecified, match the mean indices in Y to X
        if isempty( meanDex{d} )
            meanDex{d} = X.meanDex{d};
        end
        
        % Trim the Y ensemble to only allow full sequences and means
        iy = Y.trimEnsemble( 1:numel(currY), seqDex, meanDex, d );
        
        % Find the overlapping values in X and Y
        [~, ix, iy] = intersect( currX, currY(iy) );
        
        % Adjust the ensemble indices in both X and Y
        X.ensDex{d} = ix;
        Y.ensDex{d} = iy;
        
        % Note the coupling hierarchy
        