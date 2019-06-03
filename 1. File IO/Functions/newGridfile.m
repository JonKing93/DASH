function[] = newGridfile( file, gridData, gridDims, specs, varargin )
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
gridDims = setup( file, gridData, gridDims );

% Organize the metadata into a structure
meta = buildMetadata( gridDims, size(gridData), specs, varargin{:} );

% Get the set of dimension IDs
[dimID, specs] = getDimIDs;

% Permute the grid to the order of dimID
gridData = permuteGrid( gridData, gridDims, dimID );

% Build the NetCDF4 schema
schema = buildGridSchema( gridData, dimID, meta );

% Create a new NetCDF4 .grid file
ncwriteschema( file, schema );

% Write the metadata to the file
for d = 1:numel(dimID)
    ncwrite( file, dimID(d), meta.(dimID(d)) );
end

% Write the actual data and avoid the memory bug
nccreate( file, 'gridData', 'Dimensions', cellstr(dimID), ...
          'Datatype', 'double', 'FillValue', NaN );
ncwrite( file, 'gridData', gridData );

% Add the variable attributes
specField = string(fieldnames(meta.(specs)));
for f = 1:numel(specField)
    ncwriteatt( file, 'gridData', specField(f), meta.(specs).(specField(f)) );
end

end

function[gridDims] = setup( file, gridData, gridDims )
        
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
gridDims = checkGridDims(gridDims, gridData);

end