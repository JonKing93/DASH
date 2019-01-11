%% This is the coupler for state indices

% For each state dimension in Y
for yd = 1:numel(Y.dimID)
    if isState(d)
        
        % Get the 
        
        % Get the metadata from X at the state indices
        currX = xMeta.(dimID{d})(x.fixDex{d});
        
        % Get the metadata from Y for the dimension
        currY = yMeta.(dimID{d});
        
        % Ensure that none of the X metadata is repeated or NaN
        if any(isnan(currX)) || numel(unique(currX))~=numel(currX)
            error('The metadata for the template variable contains NaN or repeated values in dimension %s.', dimID{d});
        end
        
        % Find the matching indices in Y
        [c, ix, iy] = intersect( currX, currY, 'stable' );
        
        % Ensure that every X index has a matching index in Y
        if numel(ix) ~= numel(currX)
            error('Y does not have metadata matching all the values at the state indices in X for the %s dimension.', dimID{d});
        end
        
        % Set the state indices in Y to these values
        Y.fixDex{d} = iy;
        
        % Set mean properties
        Y.takeMean(d) = X.takeMean(d);
        Y.nanflag{d} = X.nanflag{d};
    end
end        