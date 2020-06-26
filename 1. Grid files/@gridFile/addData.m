function[] = addData( obj, type, file, var, dims, meta )
% Adds a data source to a .grid file.
%
% obj.add( 'nc', ncfile, var, dims, meta )
% Adds values in a netCDF file to the .grid file. 
%
% obj.add( 'mat', matfile, var, dims, meta )
% Adds values in a .mat file to the .grid file.
%
% ----- Inputs -----
%
% ncfile: The name of a netCDF file. A string. If only the file name is
%    specified, the file must be on the active path. Use the full file name
%    (including path) to add a file off the active path.
%
% matfile: The name of a .mat file. A string. If only the file name is
%    specified, the file must be on the active path. Use the full file name
%    (including path) to add a file off the active path.
%
% var: The name of the variable in the source file.
%
% dims: The order of the dimensions of the variable in the source file. A
%    string or cellstring vector.
%
% meta: A dimensional metadata structure for the data in the source file.
%    See gridfile.defineMetadata.

% Error check
if ~dash.isstrflag(type) || ~ismember(type, ["nc","mat"])
    error('The first input must be either "nc" or "mat".');
elseif ~dash.isstrflag(file)
    error('The file name must be a string scalar or character row vector.');
elseif ~dash.isstrflag(var)
    error('The variable name must be a string scalar or character row vector.');
elseif ~dash.isstrlist(dims)
    error('dims must be a string vector or cellstring vector.');
end
gridfile.checkMetadataStructure(meta);

% Check that the source file exists. Get the full name.
haspath = false;
if ~isempty(fileparts(file))
    haspath = true;
end
if haspath && ~exist(file,'file')
    error('The file %s does not exist.', file);
elseif ~haspath && ~exist(file,'file')
    error('Could not find file %s. It may be misspelled or not on the active path.', file);
end
file = which(file);

% Check that the dimensions are recognized. 
ismem = ismember(dims, dash.dimensionNames);
if any(~ismem)
    error('Element %.f of dims is not a recognized dimension name. (see dash.dimensionNames)', find(~ismem,1));
end

% Notify user that duplicate dimensions will be merged.
uniqueDims = unique(dims);
for d = 1:numel(uniqueDims)
    isdim = find(strcmp(dims, uniqueDims(d)));
    if numel(isdim) > 1
        fprintf('Dimensions %s have the same name and will be merged.\n', [sprintf('%.f, ',dim),sprintf('\b\b')] );
    end
end

% 
        

    
    



% Get source data for the data grid
dims = ' ';
if strcmp(type, 'nc')
    [path, file, var, dims, dimOrder, msize, umsize, merge, unmerge] = ...
        ncGrid.initialize( file, var, dims );
    type = 'nc   ';
    
elseif strcmp(type, 'mat')
    [path, file, var, dims, msize, umsize, merge, unmerge] = ...
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
notTS = dims( 1:numel(sourceSize) );

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
        [ismem, loc] = ismember( meta.(dims(d)), gridMeta.(dims(d)), 'rows' );
        if any( ~ismem )
            error('The %s metadata in row %.f does not match any %s metadata in file %s.', dims(d), find(~ismem,1), dims(d), file );
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