%% This adds data and extends a dimension.
function[] = extendGridfile( file, gridData, gridDims, dim, loc, meta )
%% This adds data to a gridded .mat file and extends the length of a specified
% dimension.
%
% extendGridfile( file, gridData, gridDims, dim, [], meta )
% Appends new data to the end of the specified dimension. Adds metadata for
% the new indices.
%
% extendGridfile( file, gridData, gridDims, dim, loc, meta )
% Writes new data to specific indices along the specified dimension. Adds
% metadata for all new indices, including those unspecified during writing.
%
% ----- Inputs -----
% 
% file: The name of the gridded .mat file. A string.
%
% gridData: A gridded dataset
%
% gridDims: A cell of dimension IDs indicating the order of dimensions in
%       the gridded data.
%
% dim: An ID for the dimension to be extended. A string.
%
% loc: A (2x1) vector or (1x1) scalar specifying which indices to delete.
%       Format is [START; STRIDE]. START is the index at which to begin
%       writing. STRIDE is the interval spacing between indices. If a
%       scalar, STRIDE is set to 1.
%
% meta: A vector containing metadata for the new indices along the 
%       extended dimension. (NOT a metadata structure) If STRIDE > 1, must
%       include metadata for extended indices at which data is not written.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the file
m = fileCheck(file);
dimID = m.dimID;
nDim = numel( m.dimID );

% Permute the inputs
[gridData] = permuteInputs( m, gridDims, gridData );

% Get the extended dimension
if ~ismember( dim, dimID )
    error('Unrecognized dimension for extension.');
else
    [~, exDim] = ismember(dim, dimID);
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
m.gridSize(exDim) = m.gridSize(exDim) + nAdd;

m.gridData( ic{:} ) = gridData;

% Use NaN as a fill value
if ~isempty(fillDex)
    ix = repmat( {':'}, nDim, 1 );
    ix{exDim} = fillDex;
    m.gridData( ix{:} ) = NaN;
end

end