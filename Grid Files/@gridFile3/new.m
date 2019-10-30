function[] = new( file, gridData, gridDims, appendDims, specs, varargin )
%% Creates a new gridded data (.grid) file. This is a NetCDF4 file
% built to interface with Dash.
%
% gridFile.new( file, gridData, gridDims, appendDims, specs, dimName1, dimMeta1, ..., dimNameN, dimMetaN )
% Creates a new .grid file storing gridded data and associated metadata.
%
% ----- Inputs -----
%
% file: The name of the .grid file. A string or character vector. Must have
%       a .grid extension.
%
% gridData: A gridded data set. An N-dimensional numeric array. All fill
%           values should be NaN.
%
% gridDims: A list of dimension IDs indicating the order of dimensions in
%           the gridded dataset. Either a cell vector of character vectors
%           (cellstring), or a string vector. See getDimIDs.m for a list of
%           dimension names.
%
% appendDims: A list of dimension IDs indicating the dimensions on which
%             additional data will be appended. (These will be given
%             unlimited length in the NetCDF4 file). Either a cell vector
%             of character vectors (cellstring), or a string vector.
%
% specs: A scalar structure whose fields contain non-dimensional metadata 
%        for the gridded data set. These are equivalent to variable
%        attributes in a NetCDF4 file. May include any fields. All metadata
%        must be valid NetCDF4 data types with a single row. (See listnctypes.m)
%
% dimNameN: The name of a dimension. Either a character vector or a string.
%
% dimMetaN: Metadata for dimension N. May be a vector or matrix. If a
%           vector, the length must match the size of the dimension in the
%           gridded data. If a matrix, the number of rows must match the
%           length of the dimension in the gridded data. Metadata must be a
%           vector that is a valid, numeric NetCDF4 data type. (See listnctypes.m)

% Error check. Convert names to strings, organize metadata
[gridDims, append] = setup( file, gridData, gridDims, appendDims );
gsize = gridFile.fullSize( gridData, numel(gridDims) );
meta = gridFile.buildMetadata( gridDims, gsize, specs, varargin{:} );

% Permute the grid to internal order
[dimID, specs] = getDimIDs;
gridData = gridFile.permuteGrid( gridData, gridDims, dimID );

% For each dimension, set the size or allow appending
for d = 1:numel(dimID)
    dimLength = Inf;
    if ~append(d)
        dimLength = size( gridData, d );
    end
    
    % Initialize the metadata and attributes
    dims = { dimID(d), dimLength, strcat(dimID(d),'MetaCols'), Inf };    
    nccreate(file, dimID(d), 'Format', 'netcdf4', 'Dimensions', dims, 'Datatype', class(meta.(dimID(d))) );    
    ncwriteatt( file,  dimID(d), 'append', single(append(d)) );
end
    
% Initialize the gridded data variable
nccreate( file, 'gridData', 'Dimensions', cellstr(dimID), 'Datatype', class(gridData) );

% Write the attributes
attName = string( fieldnames( meta.(specs) ) );
for a = 1:numel(attName)
    ncwriteatt( file, 'gridData', attName(a), meta.(specs).(attName(a)) );
end

% Write the gridded data and metadata
ncwrite( file, 'gridData', gridData );
for d = 1:numel(dimID)
    ncwrite( file, dimID(d), meta.(dimID(d)) );
end

end

function[gridDims, append] = setup( file, gridData, gridDims, appendDims )
        
% Check file extension and existence
gridFile.fileCheck(file, 'ext');
if exist(file, 'file')
    error('The file %s already exists!', file );
end

% Check the data is numeric
if ~isnumeric(gridData)
    error('gridData must be a numeric array.');
end

% Check the grid dimensions are recognized and non-duplicate. Convert to
% string if a cellstring
gridDims = gridFile.checkGridDims(gridDims);

% Ensure there is a gridDim for each dimension that is not a trailing singleton
nDim = 1;
if ~iscolumn(gridData)
    nDim = ndims(gridData);
end
if numel(gridDims) < nDim
    error('gridDims only contains %.f dimension IDs, but the gridded data has at least %.f dimensions.', numel(gridDims), nDim);
end

% Error check the append dims. Sort to match the order of dimID
append = gridFile.checkAppendDims( appendDims );

end