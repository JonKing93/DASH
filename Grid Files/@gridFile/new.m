function[] = new( filename, type, source, varName, dimOrder, atts, varargin )
%% Creates a new gridded data (.grid) file. This is a container object that
% contains instructions on reading data from different sources, including:
% NetCDF files, .mat Files, and Matlab numeric arrays.
%
% gridFile.new( filename, 'nc', ncfile, varName, dimOrder, attributes, dimName1, dimMeta1, ..., dimNameN, dimMetaN ) 
% Creates a new .grid file from data in a NetCDF file.
%
% gridFile.new( filename, 'mat', matfile, varName, dimOrder, attributes, dimName1, dimMeta1, ..., dimNameN, dimMetaN ) 
% Creates a new .grid file from data in a .mat file.
%
% gridFile.new( filename, 'array', X, [], dimOrder, attributes, dimName1, dimMeta1, ..., dimNameN, dimMetaN ) 
% Creates a new .grid file from a numeric array.

% Error check. Convert to strings for internal use.
[dimOrder] = setup( filename, type, dimOrder );

% Create the appropriate data source object
if strcmpi( type, 'nc' )
    sourceGrid = ncGrid( source, varName, dimOrder );
elseif strcmpi( type, 'mat' )
    sourceGrid = matGrid( source, varName, dimOrder );
else
    sourceGrid = arrayGrid( source, filename, 'data1', dimOrder );
end

% Get the initial grid size. Check there is a named dimension for each
% non-trailing singleton
gridSize = sourceGrid.size(:)';
if numel( dimOrder ) < numel( gridSize )
    error('dimOrder only contains %.f dimensions, but the gridded source data has %.f dimensions.', numel(dimOrder), numel(gridSize) );
end

% Organize the metadata.
meta = gridFile.buildMetadata( dimOrder, gridSize, atts, varargin{:} );

% Reorder size to match the internal dimension order
gridDims = getDimIDs;
nDim = numel(gridDims);
gridSize = gridFile.fullSize( sourceGrid.size(:)', nDim );
gridSize = gridFile.permuteSize( gridSize, dimOrder, gridDims );

% Get the dimension limits of the data source
dimLimit = [ones(nDim,1), gridSize'];

% Create the new .grid file. Add in the data source, metadata, dimension
% order, dimension limts. 
m = matfile( filename );
m.source = sourceGrid;
m.dimOrder = gridDims;
m.dimLimit = dimLimit;
m.metadata = meta;
m.gridSize = gridSize;

% If the data source is an array, save it directly to the file
if isa(sourceGrid,'arrayGrid')
    m.data1 = source;
end

end

% Initial error checking
function[dimOrder] = setup( filename, type, dimOrder )

% Check file extension and existence.
gridFile.fileCheck( filename, 'ext' );
if exist(filename, 'file')
    error('The file %s already exists!', file );
end

% Check the type is recognized
if ~isstrflag( type ) || ~ismember( type, ["nc","mat","array"] )
    error('type must either be "nc", "mat", or "array"');
end

% Check the grid dimensions are recognized and non-duplicate. Convert to string
dimOrder = gridFile.checkSourceDims( dimOrder );

end