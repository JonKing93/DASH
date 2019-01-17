function[ic, ix] = getFixedIndexCell( fixDex )
%% This determines whether a set of fixed indices are equally spaced
%
% fixDex = {latDex, lonDex, levDex, NaN, NaN}

% Preallocate a logical for whether each set of fixed indices has an equal
% interval spacing
fixInterval = false( nDim, 1 );

% For each set of indices
for d = 1:nDim
    % If there are fixed indices
    if ~isnan( fixDex(d) )
        % Check the spacing on the fixed indices
        interval = diff( fixDex{d} );
        
        % If there is only one spacing interval, then set the logical
        if numel( unique(interval) ) == 1
            fixInterval(d) = true;
        end
    end
end

% Get an index cell to use for each ensemble member
ic = cell( nDim, 1 );

% Set any fixed indices with equal spacing
ic( fixed & fixInterval ) = fixDex( fixed & fixInterval );

% Set any fixed indices without equal spacing
ic{ fixed & ~fixInterval } = ':';

% Get a separate index cell to restrict fixed indices with unequal spacing
% after the full dimension has been loaded.
ix = repmat( {':'}, nDim, 1 );
ix( fixed & ~fixInterval ) = fixDex( fixed & ~fixInterval );

end