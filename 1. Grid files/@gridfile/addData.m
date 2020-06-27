function[] = add( obj, type, file, var, dims, meta )
% Adds a data source to a .grid file.
%
% obj.add( type, file, var, dims, meta )
% Adds values in a data file to the .grid file.
%
% ----- Inputs -----
%
% type: The type of data source. A string. 
%    "nc": Use when the data source is a NetCDF file.
%    "mat": Use when the data source is a .mat file.
%
% file: The name of the data source file. A string. If only the file name is
%    specified, the file must be on the active path. Use the full file name
%    (including path) to add a file off the active path.
%
% var: The name of the variable in the source file.
%
% dims: The order of the dimensions of the variable in the source file. A
%    string or cellstring vector.
%
% meta: The dimensional metadata structure for the data in the source file.
%    See gridfile.defineMetadata.

% Create the dataSource object. This will error check type, file, var, and
% dims. It also has information on the size of the merged / unmerged data.
source = dataSource.new(type, file, var, dims);

% Check that the dimensions are all in the grid
recognized = ismember(dims, obj.dims);
if any(~recognized)
    error('Element %.f in dims (%s) is not a dimension recognized by this gridfile. See <location>.', find(~recognized,1), dims(find(~recognized,1)) );
end

gridfile.checkMetadataStructure(meta);







        

    
    



% Get source data for the data grid
dims = ' ';
if strcmp(type, 'nc')
    [path, file, var, dims, dimOrder, msize, umsize, merge, unmerge] = ...
        ncGrid.initialize( file, var, dims );
    type = 'nc   ';
    
elseif strcmp(type, 'mat')
    [path, file, var, dimOrder, msize, umsize, merge, unmerge] = ...
        matGrid.initialize( file, var, dims );
    type = 'mat  ';
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
tsDim = ~ismember(gridDims, dims);
dims(end+(1:sum(tsDim))) = gridDims( tsDim );
dimLimit = NaN( nDims, 2 );

% For each dimension with metadata
for d = 1:nDims    
    if isfield( meta, dims(d) )
        
        % Check the number of metadata rows match the size of the dimension
        if size(meta.(dims(d)),1) ~= sourceSize(d)
            error('The number of "%s" metadata rows (%.f) does not match the size of the dimension (%.f) in the data source', dims(d), size(meta.(dims(d)),1), sourceSize(d) );
        end
        
        % Check the metadata is an exact, increasing sequence within the
        % grid metadata
        [recognized, loc] = ismember( meta.(dims(d)), gridMeta.(dims(d)), 'rows' );
        if any( ~recognized )
            error('The %s metadata in row %.f does not match any %s metadata in file %s.', dims(d), find(~recognized,1), dims(d), file );
        elseif size(meta.(dims(d)),1)>1 && issorted( loc, 'strictdescend' )
            error('The %s metadata is in the opposite order of file %s.', dims(d), file );
        elseif ~issorted( loc, 'strictascend' )
            error('The %s metadata is ordered differently than in file %s.', dims(d), file );
        elseif size(meta.(dims(d)),1)>1 && ~isequal( unique(diff(loc)), 1 )
            error('The %s metadata skips elements that are in file %s.', dims(d), file );
        end
        
        % Get the dimension limits
        dimLimit(d,:) = [min(loc), max(loc)];
    
    % If not a metadata field, this is a trailing singleton. Limits are 1
    else
        dimLimit(d,:) = [1 1];
    end 
end

% Reorder the limits to match the internal .grid dimension order
[~, reorder] = ismember( gridDims, dims );
dimLimit = dimLimit(reorder,:);

% Check that the data does not overlap with other existing data
gridFile.checkOverlap( dimLimit, obj.dimLimit(:,:,1:obj.nSource) );

% Load the file variables. Ensure correct sizing
try
    m = load( obj.filepath, '-mat' );
    dims = gridData.dims2char( dims );
    newVars = {path, file, var, dims, dims, msize, umsize, merge, unmerge};
    [m, newVars, counter] = gridFile.ensureFieldSize( m, newVars );
    
    % Update the file variables.
    valid = true;
    dims = m.dimOrder;
    gridSize = m.gridSize;
    metadata = m.metadata;
    nSource = obj.nSource + 1;
    dimLimit = cat(3, m.dimLimit, dimLimit );
    sourcePath = cat(1, m.sourcePath, newVars{1} );
    sourceFile = cat(1, m.sourceFile, newVars{2} );
    sourceVar = cat(1, m.sourceVar, newVars{3} );
    sourceDims = cat(1, m.sourceDims, newVars{4} );
    sourceOrder = cat(1, m.sourceOrder, newVars{5} );
    sourceSize = cat(1, m.sourceSize, newVars{6} );
    unmergedSize = cat(1, m.unmergedSize, newVars{7} );
    merge = cat(1, m.merge, newVars{8} );
    unmerge = cat(1, m.unmerge, newVars{9} );
    counter = cat(1, m.counter, counter);
    maxCounter = m.maxCounter;
    type = cat(1, m.type, type );    
    
    save( obj.filepath, '-mat', 'valid', 'dimOrder', 'gridSize', 'metadata', ...
          'nSource', 'dimLimit', 'sourcePath', 'sourceFile', 'sourceVar', 'sourceDims', ...
          'sourceOrder','sourceSize','unmergedSize','merge','unmerge','counter', 'maxCounter', 'type' );
    
% If the write operation failed, delete the object.
catch ME
    [~, killStr] = fileparts( obj.filepath );
    delete( obj );
    error('Failed to add new data source. The file %s is no longer valid. Deleting the current gridFile object.', killStr);
end
    
% Update user object
obj.update;   

end