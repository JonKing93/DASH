function[grid] = new( filename, meta, attributes, overwrite )
%% Initializes a new .grid file. Each .grid file organizes a collection of
% gridded data. The .grid file stores instructions on how to read data from
% different sources (such as NetCDF and .mat files), and organizes metadata
% for the values in each data source.
%
% gridfile.new( filename, meta )
% Initializes a new .grid file with dimensional metadata. If only a file
% name is specified, creates the file in the current directory. Use a full
% file name (including path) to create the .grid file in a custom
% directory. Adds a ".grid" extension to the file name if it does not
% already have one.
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
if ~exist('attributes','var')
    attributes = [];
end
if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = false;
end

% Error check
dash.assertStrFlag( filename, "filename" );
if ~isempty(attributes)  && (~isstruct(attributes) || ~isscalar(attributes))
    error('attributes must be a scalar struct.');
elseif ~islogical(overwrite) || ~isscalar(overwrite)
    error('overwrite must be a scalar logical.');
end
gridfile.checkMetadataStructure( meta );

% Ensure the file name has a .grid extension
filename = char( filename );
[path, ~, ext] = fileparts( filename );
if ~strcmpi(ext, '.grid')
    filename = [filename, '.grid'];
end

% Get the full name for the file. If not overwriting, ensure that the file
% does not already exist.
if isempty(path)
    filename = fullfile(pwd, filename);
end
if ~overwrite && exist(filename,'file')
    error('The file %s already exists.', filename );
end

% Get all internal metadata names.
dims = dash.dimensionNames;
atts = gridfile.attributesName;
nDim = numel(dims);

% Initialize metadata variables
metadata = struct();
isdefined = false(1,nDim);
gridSize = NaN(1,nDim);

% Build the internal metadata structure. Use NaN as metadata for
% dimensions with undefined metadata.
for d = 1:nDim
    if isfield(meta, dims(d))
        metadata.(dims(d)) = meta.(dims(d));
        gridSize(d) = size( meta.(dims(d)), 1 );
        isdefined(d) = true;
    else
        metadata.(dims(d)) = NaN;
        gridSize(d) = 1;
    end
end
if ~isempty(attributes)
    metadata.(atts) = attributes;
end

% Initialize the data source information
source = struct('file',[],'var',[],'dataType',[],'unmergedDims',[],...
                'unmergedSize',[],'merge',[],'mergedDims',[],...
                'mergedSize',[]);
nField = numel(fields(source));
fieldLength = NaN(0, nField);
maxLength = zeros(1, nField);
dimLimit = NaN(nDim, 2, 0);
            
% Create the initial .grid file.
% dims              % The internal dimension order in the .grid file
% gridSize;         % The size of each dimension
% isdefined         % Whether a dimension has defined metadata
% metadata          % The metadata along each dimension (and also non-dimensional attributes)
% source            % The data sources organized by the .grid file.
% fieldLength       % Length of the primitive arrays for each source
% maxLength         % Length of the padded primitive arrays in the .grid file
% dimLimit          % The index limits of each data source along each dimension (nDim x 2 x nSource)
save( filename, '-mat', 'dims', 'gridSize', 'isdefined', 'metadata', ...
      'source', 'fieldLength', 'maxLength', 'dimLimit' );

% Return grid object as output
grid = gridfile( filename );

end