function[] = addData( file, type, source, varName, dimOrder, meta )
% Adds a data source to a .grid file.
%
% gridFile.addData( file, 'nc', ncFile, varName, dimOrder, meta )
% Adds data from a netCDF file.
%
% gridFile.addData( file, 'mat', matFile, varName, dimOrder, meta )
% Adds data from a saved .mat file.
%
% gridFile.addData( file, 'array', X, [], dimOrder, meta )
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

% Check the file is grid / exists
gridFile.fileCheck( file );
m = matfile( file, 'Writable', true );

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

% Build the source grid
if strcmp(type, 'nc')
    sourceGrid = ncGrid( source, varName, dimOrder );
elseif strcmp(type, 'mat')
    sourceGrid = matGrid( source, varName, dimOrder );
elseif strcmp(type, 'array')
    dataName = sprintf('data%.f', numel(m.source)+1);
    sourceGrid = arrayGrid( source, dataName, dimOrder );
end
dimOrder = sourceGrid.dimOrder;

% Get the grid dimensions that have metadata (i.e. are not unspecified
% singletons)
gridDims = m.dimOrder;
nDims = numel( gridDims );
gridMeta = m.metadata;

notnan = false( 1, nDims );
for d = 1:nDims
    if ~isscalar(gridMeta.(gridDims(d))) || ~isnumeric(gridMeta.(gridDims(d))) || ~isnan(gridMeta.(gridDims(d)))
        notnan(d) = true;
    end
end
notnanDim = gridDims( notnan );

% Get the source dimensions that are not trailing singletons
sourceSize = sourceGrid.squeezeSize( sourceGrid.size );
notTS = sourceGrid.dimOrder( 1:numel(sourceSize) );

% Ensure that both the non-nan grid dims, and the non-TS dims have metadata
needMeta = unique( [notnanDim, notTS] );
metaDims = string( fields(meta) );

hasmeta = ismember( needMeta, metaDims );
if any( ~hasmeta )
    error('There must be metadata for the %s dimension.', needMeta(find(~hasmeta,1)) );
end

% Get the size and name of all dimensions for the source grid.
sourceSize = sourceGrid.fullSize( sourceGrid.size, nDims );
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
gridFile.checkOverlap( dimLimit, m.dimLimit );

% Add the new data source to the .grid file
newSource = m.source;
newSource{end+1,1} = sourceGrid;
newLimit = m.dimLimit;
newLimit = cat(3, newLimit, dimLimit);

m.valid = false;
m.nSource = m.nSource + 1;
m.source = newSource;
m.dimLimit = newLimit;
if isa(sourceGrid, 'arrayGrid')
    m.(dataName) = source;
end
m.valid = true;
    
end