%% This adds new data to indices.
function[] = indexGridfile( file, gridData, gridDims, loc, meta )

% Error check the file
m = fileCheck(file);
nDim = numel(m.dimID);

% Permute inputs to match the existing file
[gridData, loc] = permuteInputs( m, gridDims, gridData, loc );

% Get the cell of indices
[ic, nAdd] = getIndexCell( m, fullSize(gridData,nDim), loc );

% Error check
if sum( nAdd>0 ) > 0
    dimID = m.dimID;
    error('The %s dimension is being extended. Use extendGridfile.m instead.', dimID{find(nAdd>0,1)} );
elseif exist('meta','var')
    compareMetadata( m, meta, ic );
end

% Add the indexed data
m.gridData( ic{:} ) = gridData;

end
