function[] = newGridfile( file, gridData, gridDims, specs, varargin )
%% Creates a new gridded data (.grid) file. Uses NetCDF4 to store data.
%
% newGridfile( file, gridData, gridDims, meta )
% Creates a new gridded .mat file. Checks that metadata matches data size
% in all dimensions.
%
% ----- Inputs -----
%
% file: The name of the .grid file. A string.
%
% gridData: A gridded data set.
%
% gridDims: A cell of dimension IDs indicating the order of dimensions in
%       the gridded data.
%
% meta: A metadata structure for the gridded data. See the buildMetadata.m
%       function.

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
nccreate( file, 'gridData', 'Dimensions', {'lon','lat','lev','time'}, ...
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

% Check the data is a netcdf type
if ~isnctype(gridData)
    error('gridData is not a supported NetCDF4 data type (See listNcType.m).');
end

% Check the grid dimensions
gridDims = checkGridDims(gridDims, gridData);

end