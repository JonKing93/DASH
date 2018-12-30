%% This adds data and extends a dimension.
function[] = extendGridfile( file, gridData, gridDims, dim, loc, meta )

% Error check the file
m = fileCheck(file);
nDim = numel( m.dimID );

% Permute the inputs
[gridData] = permuteInputs( m, gridDims, gridData );

% Get the extended dimension
if ~ismember( dim, m.dimID )
    error('Unrecognized dimension for extension.');
else
    exDim = find( ismember(dim, m.dimID) );
end

% Get the size of the existing extended dimension
nOld = size(m.gridData, exDim);

% Set a loc for the extended dimension if unspecified
if isempty(loc)
    loc = nOld + 1;
end

% Permute the locs
dimLoc = NaN( size(loc,1), nDim );
dimLoc(:, exDim) = loc;

% Get the index cell
[ic, nAdd] = getIndexCell( m, fullSize(gridData,nDim), dimLoc );

% Get some metadata values for the existing data
dimID = m.dimID;
oldMeta = m.meta;

% Error checking
if sum(nAdd>0) > 1
    error('Can only extend one dimension. Currently, the %s and %s dimensions are both being extended.', ...
        dimID{find(nAdd>0,1,'first')}, dimID{find(nAdd>0,1,'last')} );
elseif ~isvector(meta) || length(meta)~=nAdd(nAdd>0)
    error(['The extended metadata must be a vector the length of the number of new indices.',...
           newline, 'This includes indices with unspecified data.'] );
elseif ~isequal( class(oldMeta.(dimID{exDim})), class(meta) )
    error('The new metadata is a different class than the field in the existing metadata.');
end

% Get the indices of any fill values
nAdd = nAdd(nAdd>0);
newDex = nOld+1 : nOld+nAdd;
fillDex = newDex( ~ismember(newDex, ic{exDim}) );

% Add the new data
oldMeta.(dimID{exDim})(newDex) = meta;
m.meta = oldMeta;

m.gridData( ic{:} ) = gridData;

% Use NaN as a fill value
if ~isempty(fillDex)
    ix = repmat( {':'}, nDim, 1 );
    ix{exDim} = fillDex;
    m.gridData( ix{:} ) = NaN;
end

end