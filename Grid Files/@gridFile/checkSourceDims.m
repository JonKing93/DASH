function[sourceDims] = checkSourceDims( sourceDims)
%% Check that listed dimensions are recognized and non-duplicate
%
% checkSourceDims( dimOrder )

% Check that this is a list of dimension IDs
sourceDims = gridFile.checkDimList( sourceDims, 'sourceDims' );

% Check for duplicates
if numel(sourceDims) ~= numel(unique(sourceDims))
    error('gridDims cannot contain repeat dimensions.');
end

end