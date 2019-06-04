function[] = newGridfile( file, gridData, gridDims, appendDims, specs, varargin )
%% Creates a new gridded data (.grid) file. This is a NetCDF4 file that is
% custom built to interface with Dash.
%
% newGridfile( file, gridData, gridDims, specs, dimName1, dimMeta1, ..., dimNameN, dimMetaN )
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
%           (cellstring), or a string vector. 
%
% appendDims: A list of dimension IDs indicating the dimensions on which
%             additional data will be appended. (These will be given
%             unlimited length in the NetCDF4 file). Either a cell vector
%             of character vectors (cellstring), or a string vector.
%
% specs: A scalar structure whose fields contain non-dimensional metadata 
%        for the gridded data set. These are equivalent to variable
%        attributes in a NetCDF4 file.
%
% dimNameN: The name of a dimension. Either a character vector or a string.
%
% dimMetaN: Metadata for dimension N. May be a vector or matrix. If a
%           vector, the length must match the size of the dimension in the
%           gridded data. If a matrix, the number of rows must match the
%           length of the dimension in the gridded data. Metadata must be a
%           vector that is a valid NetCDF4 data type. (See listnctypes.m)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check. Convert names to strings.
[gridDims, append] = setup( file, gridData, gridDims, appendDims );

% Error check metadata and organize into a structure.
gsize = fullSize( gridData, numel(gridDims) );
meta = buildMetadata( gridDims, gsize, specs, varargin{:} );

% Get the set of dimension IDs and the append notifications
[dimID, specs] = getDimIDs;

% Permute the grid to the order of dimID and get the size
gridData = permuteGrid( gridData, gridDims, dimID );

% For each dimension
for d = 1:numel(dimID)
    
    % Get the length of the dimension. If an append dimension, allow
    % unlimited length. If not, use the current size.
    dimLength = Inf;
    if ~append(d)
        dimLength = size( gridData, d );
    end
    
    % Get the metadata dimensions. Allow the metadata columns to be
    % unlimited
    dims = { dimID(d), dimLength, strcat(dimID(d),'MetaCols'), Inf };
    
    % Initialize the metadata variable    
    nccreate(file, dimID(d), 'Format', 'netcdf4', 'Dimensions', dims );
    
    % Set an attribute for the number of columns
    ncwriteatt( file, dimID(d), 'nCols', size(meta.(dimID(d)), 2) );
    
    % Set an attribute for whether appending is allowed
    ncwriteatt( file,  dimID(d), 'append', single(append(d)) );
end
    
% Initialize the gridded data variable
nccreate( file, 'gridData', 'Dimensions', cellstr(dimID) );

% Next, get all the data attributes
attName = string( fieldnames( meta.(specs) ) );

% Write each attribute
for a = 1:numel(attName)
    ncwriteatt( file, 'gridData', attName(a), meta.(specs).(attName(a)) );
end

% Now that the NetCDF4 header is complete, start writing actual data

% Then write the metadata variables
for d = 1:numel(dimID)
    ncwrite( file, dimID(d), meta.(dimID(d)) );
end

% Finally, write in the variable
ncwrite( file, 'gridData', gridData );

end

function[gridDims, append] = setup( file, gridData, gridDims, appendDims )
        
% Check for .grid extension
fileCheck(file, 'ext');

% Abort if the file exists
if exist(file, 'file')
    error('The file %s already exists!', file );
end

% Check the data is numeric
if ~isnumeric(gridData)
    error('gridData must be a numeric array.');
end

% Check the grid dimensions are recognized and non-duplicate. Convert to
% string if a cellstring
gridDims = checkGridDims(gridDims);

% Ensure there is a gridDim for each dimension that is not a trailing singleton
nDim = 1;
if ~iscolumn(gridData)
    nDim = ndims(gridData);
end
if numel(gridDims) < nDim
    error('gridDims only contains %.f dimension IDs, but the gridded data has at least %.f dimensions.', numel(gridDims), nDim);
end

% Error check the append dims. Sort to match the order of dimID
append = checkAppendDims( appendDims );

end