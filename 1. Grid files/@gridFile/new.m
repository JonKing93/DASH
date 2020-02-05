function[grid] = new( filename, meta, attributes )
%% Initializes a new gridded data (.grid) file. This is a container object that
% contains instructions on reading data from different sources, including:
% NetCDF files, .mat Files, and Matlab workspace arrays.
%
% gridFile.new( filename, meta )
% Initializes a new .grid file with pre-defined dimensional metadata.
%
% gridFile.new( filename, meta, attributes )
% Includes any desired non-dimensional metadata.
%
% ----- Inputs -----
%
% filename: The name of the .grid file
%
% meta: A metadata structure defining the grid. See gridFile.defineMetadata
%
% attributes: A scalar structure whose fields contain any non-dimensional
%             metadata of interest.

% Check the file extension and that it does not exist
gridFile.fileCheck( filename, 'ext' );
if exist(fullfile(pwd,filename),'file')
    error('The file %s already exists!', filename );
end
filename = fullfile(pwd,filename);

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
counter = [];    % Has 9 cols
type = '';
save( filename, '-mat', 'valid', 'dimOrder', 'gridSize', 'metadata', ...
      'nSource', 'dimLimit', 'sourcePath', 'sourceFile', 'sourceVar', 'sourceDims', ...
      'sourceOrder', 'sourceSize', 'unmergedSize', 'merge', 'unmerge', ...
      'counter', 'type' );

% Return grid object as output
grid = gridFile( filename );

end