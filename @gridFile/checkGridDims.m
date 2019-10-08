function[gridDims] = checkGridDims(gridDims)
%% Check that listed dimensions are recognized and non-duplicate
%
% checkDims(gridDims, gridData)

% Check that this is a list of dimension IDs
gridDims = gridFile.checkDimList( gridDims, 'gridDims' );

% Check for duplicates
if numel(gridDims) ~= numel(unique(gridDims))
    error('gridDims cannot contain repeat dimensions.');
end

end