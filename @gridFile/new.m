function[] = new( filename, meta, attributes )
%% Initializes a new gridded data (.grid) file. This is a container object that
% contains instructions on reading data from different sources, including:
% NetCDF files, .mat Files, and Matlab numeric arrays.
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
[dimID, attsName] = getDimIDs;
nDim = numel(dimID);
allmeta = struct();
gridSize = NaN(1, nDim);

for d = 1:nDim
    if isfield( meta, dimID(d) )
        allmeta.( dimID(d) ) = meta.( dimID(d) );
        gridSize(d) = size( meta.(dimID(d)), 1 );
    else
        allmeta.( dimID(d) ) = NaN;
        gridSize(d) = 1;
    end
end
if ~isempty( attributes )
    allmeta.(attsName) = attributes;
end

% Initialize the .grid file
m = matfile( filename );
m.valid = false;
m.dimOrder = dimID;
m.gridSize = gridSize;
m.metadata = allmeta;

m.nSource = 0;
m.source = {};
m.dimLimit = [];
m.valid = true;

end