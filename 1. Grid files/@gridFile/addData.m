function[] = addData( obj, type, source, varName, dimOrder, meta )
% Adds a data source to a .grid file.
%
% gridFile.addData( obj, 'nc', ncFile, varName, dimOrder, meta )
% Adds data from a netCDF file.
%
% gridFile.addData( obj, 'mat', matFile, varName, dimOrder, meta )
% Adds data from a saved .mat file.
%
% gridFile.addData( obj, 'array', X, [], dimOrder, meta )
% Adds data from a workspace array. Saves the array directly to file.
%
% ----- Inputs ----
%
% file: The name of the .grid file. A string. Must end with ".grid"
%
% ncFile: The name of a NetCDF file. Must be on the active path. A string.
%
% matFile: The name of a .mat file. Must be on the active path. A string.
%
% X: A numeric or logical array.
%
% varName: The name of a variable in a NetCDF or .mat file.
%
% dimOrder: The order of the dimensions in the data source.
%
% meta: A metadata structure for the data source. See gridFile.defineMetadata
%       for details.

% Update the grid file in case changes have been made
obj.update;

% Check the type is recognized
if ~isstrflag( type )
    error('type must be a string scalar or character row vector.');
elseif ~ismember( type, ["nc","mat","array"])
    error('type must be either "nc", "mat", or "array".');
end

% Check that the source grid dimensions are recognized and non-duplicate,
% and that the metadata is allowed
[dimOrder] = gridFile.checkSourceDims( dimOrder );
gridFile.checkMetadata( meta );

% Get source data for the data grid
dims = ' ';
if strcmp(type, 'nc')
    [path, file, var, dims, dimOrder, msize, umsize, merge, unmerge] = ...
        ncGrid.initialize( source, varName, dimOrder );
    type = 'nc   ';
    
elseif strcmp(type, 'mat')
    [path, file, var, dimOrder, msize, umsize, merge, unmerge] = ...
        matGrid.initialize( source, varName, dimOrder );
    type = 'mat  ';
    
elseif strcmp(type, 'array')
    [source, file, var, dimOrder, msize, umsize, merge, unmerge] = ...
        arrayGrid.initialize( source, obj.nSource, dimOrder );
    path = char( obj.filepath );
end

% Get the grid dimensions that have metadata (i.e. are not unspecified
% singletons)
gridDims = obj.dimOrder;
nDims = numel( gridDims );
gridMeta = obj.metadata;

notnan = false( 1, nDims );
for d = 1:nDims
    if ~isscalar(gridMeta.(gridDims(d))) || ~isnumeric(gridMeta.(gridDims(d))) || ~isnan(gridMeta.(gridDims(d)))
        notnan(d) = true;
    end
end
notnanDim = gridDims( notnan );

% Get the source dimensions that are not trailing singletons
sourceSize = gridData.squeezeSize( msize );   
notTS = dimOrder( 1:numel(sourceSize) );

% Ensure that both the non-nan grid dims, and the non-TS dims have metadata
needMeta = unique( [notnanDim, notTS] );
metaDims = string( fields(meta) );

hasmeta = ismember( needMeta, metaDims );
if any( ~hasmeta )
    error('There must be metadata for the %s dimension.', needMeta(find(~hasmeta,1)) );
end

% Get the size and name of all dimensions for the source grid.
sourceSize = gridData.fullSize( msize, nDims );
tsDim = ~ismember(gridDims, dimOrder);
dimOrder(end+(1:sum(tsDim))) = gridDims( tsDim );
dimLimit = NaN( nDims, 2 );

% For each dimension with metadata
for d = 1:nDims    
    if isfield( meta, dimOrder(d) )
        
        % Check the number of metadata rows match the size of the dimension
        if size(meta.(dimOrder(d)),1) ~= sourceSize(d)
            error('The number of "%s" metadata rows (%.f) does not match the size of the dimension (%.f) in the data source', dimOrder(d), size(meta.(dimOrder(d)),1), sourceSize(d) );
        end
        
        % Check the metadata is an exact, increasing sequence within the
        % grid metadata
        [ismem, loc] = ismember( meta.(dimOrder(d)), gridMeta.(dimOrder(d)), 'rows' );
        if any( ~ismem )
            error('The %s metadata in row %.f does not match any %s metadata in file %s.', dimOrder(d), find(~ismem,1), dimOrder(d), file );
        elseif size(meta.(dimOrder(d)),1)>1 && issorted( loc, 'strictdescend' )
            error('The %s metadata is in the opposite order of file %s.', dimOrder(d), file );
        elseif ~issorted( loc, 'strictascend' )
            error('The %s metadata is ordered differently than in file %s.', dimOrder(d), file );
        elseif size(meta.(dimOrder(d)),1)>1 && ~isequal( unique(diff(loc)), 1 )
            error('The %s metadata skips elements that are in file %s.', dimOrder(d), file );
        end
        
        % Get the dimension limits
        dimLimit(d,:) = [min(loc), max(loc)];
    
    % If not a metadata field, this is a trailing singleton. Limits are 1
    else
        dimLimit(d,:) = [1 1];
    end 
end

% Reorder the limits to match the internal .grid dimension order
[~, reorder] = ismember( gridDims, dimOrder );
dimLimit = dimLimit(reorder,:);

% Check that the data does not overlap with other existing data
gridFile.checkOverlap( dimLimit, obj.dimLimit );

% Preallocate more space if the fields need expanding
dimOrder = gridData.dims2char( dimOrder );
counter = [numel(path), numel(file), numel(var), numel(dims), numel(dimOrder), ...
           numel(msize), numel(umsize), numel(merge), numel(unmerge)];
s = obj.nSource + 1;
obj.ensureFieldSize( s, counter )

% Write to file
try
    m = matfile( obj.filepath, 'Writable', true );
    m.valid = false;
    m.nSource = s;
    m.dimLimit(:,:,s) = dimLimit;
    
    m.sourcePath(s, 1:counter(1)) = path;
    m.sourceFile(s, 1:counter(2)) = file;
    m.sourceVar(s, 1:counter(3)) = var;
    m.sourceDims(s, 1:counter(4)) = dims;
    m.sourceOrder(s, 1:counter(5)) = dimOrder;
    m.sourceSize(s, 1:counter(6)) = msize;
    m.unmergedSize(s, 1:counter(7)) = umsize;
    m.merge(s, 1:counter(8)) = merge;
    m.unmerge(s, 1:counter(9)) = unmerge;
    m.counter(s, :) = counter;
    m.type(s,:) = type;
    
    % Save workspace arrays directly to file
    if strcmp( type, 'array' )
        m.(var) = source;
    end
    
    % Nice job, successful write
    m.valid = true;
    
% If the write operation failed, delete the object.
catch ME
    [~, killStr] = fileparts( obj.filepath );
    delete( obj );
    error('Failed to add new data source. The file %s is no longer valid. Deleting the current gridFile object.', killStr);
end
    
end