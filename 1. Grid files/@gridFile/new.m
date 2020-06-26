function[grid] = new( filename, meta, attributes, overwrite )
%% Initializes a new .grid file. Each .grid file organizes a collection of
% gridded data. The .grid file stores instructions on how to read data from
% different sources (such as NetCDF and .mat files), and organizes metadata
% for the values in each data source.
%
% gridfile.new( filename, meta )
% Initializes a new .grid file with dimensional metadata. If only a file
% name is specified, creates the file in the current directory. Use a full
% file path to create the .grid file in a custom directory. Adds a ".grid"
% extension to the file name if it does not already have one.
%
% gridfile.new( filename, meta, attributes )
% Includes additional non-dimensional metadata in the .grid file.
%
% gridfile.new( filename, meta, attributes, overwrite )
% Specify whether the method may overwrite a pre-existing file.
%
% ----- Inputs -----
%
% filename: The name of the .grid file. A string. Use only a file name to
%    write to the current directory. Use a full path to write to a
%    custom location.
%
% meta: Dimensional metadata for the grid. See gridfile.defineMetadata.
%
% attributes: A scalar structure. Any fields are allowed, and should store
%    non-dimensional metadata for the grid. If attributes=[], no
%    non-dimensional metadata is included for the grid.
%
% overwrite: A scalar logical. Indicates whether the method may overwrite
%    an existing file. Default is false.

% Default values of unset inputs
if ~exist('attributes','var') || isempty(attributes)
    attributes = struct();
end
if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = false;
end

% Error check
if ~isstrflag(filename)
    error('filename must be a string scalar or character row vector.');
elseif ~isstruct(attributes) || ~isscalar(attributes)
    error('attributes must be a scalar struct.');
elseif ~islogical(overwrite) || ~isscalar(overwrite)
    error('overwrite must be a scalar logical.');
end
gridfile.checkMetadataStructure( meta );

% Ensure the file name has a .grid extension
filename = char( filename );
[path, name, ext] = fileparts( filename );
if ~strcmpi(ext, '.grid')
    filename = [filename, '.grid'];
end

% Get the full name for the file. If not overwriting, ensure that the file
% does not already exist.
if isempty(path)
    filename = fullfile(pwd, filename);
end
if ~overwrite && exist(filename, 'file')
    error('The file %s already exists.', filename );
end




% Check that the metadata structure is valid
gridFile.checkMetadata( meta );

% Error check attributes / set default
if ~exist('attributes','var')
    attributes = [];
elseif ~isstruct(attributes) || ~isscalar(attributes)
    error('attributes must be a scalar struct.');
end

% Get the internal metadata structure. Include attributes. Give undefined
% dimensions NaN metadata
[dimOrder, attsName] = getDimIDs;
nDim = numel(dimOrder);
metadata = struct();
gridSize = NaN(1, nDim);

for d = 1:nDim
    if isfield( meta, dimOrder(d) )
        metadata.( dimOrder(d) ) = meta.( dimOrder(d) );
        gridSize(d) = size( meta.(dimOrder(d)), 1 );
    else
        metadata.( dimOrder(d) ) = NaN;
        gridSize(d) = 1;
    end
end
if ~isempty( attributes )
    metadata.(attsName) = attributes;
end

% Initialize the .grid file
valid = true;
nSource = 0;
dimLimit = [];
sourcePath = '';
sourceFile = '';
sourceVar = '';
sourceDims = '';
sourceOrder = '';
sourceSize = [];
unmergedSize = [];
merge = [];
unmerge = [];
counter = [];
maxCounter = zeros(1,9);
type = '';
save( filename, '-mat', 'valid', 'dimOrder', 'gridSize', 'metadata', ...
      'nSource', 'dimLimit', 'sourcePath', 'sourceFile', 'sourceVar', 'sourceDims', ...
      'sourceOrder', 'sourceSize', 'unmergedSize', 'merge', 'unmerge', ...
      'counter', 'maxCounter', 'type' );

% Return grid object as output
grid = gridFile( filename );

end