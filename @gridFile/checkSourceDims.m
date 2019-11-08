function[sourceDims] = checkSourceDims( sourceDims)
%% Check that listed dimensions are recognized and non-duplicate
%
% checkSourceDims( dimOrder )

% Check that this is a list of dimension IDs
sourceDims = gridFile.checkDimList( sourceDims, 'dimOrder' );

% Check for duplicates. Notify the user that duplicate dimensions will be merged
uniqDims = unique( sourceDims );
for d = 1:numel(uniqDims)
    dim = find( strcmp( uniqDims(d), sourceDims ) );
    if numel( dim ) > 1
        dimstr = [sprintf('%.f, ', dim), sprintf('\b\b')];
        fprintf( 'Dimensions %s have the same ID and will be merged.\n', dimstr );
    end
end

end