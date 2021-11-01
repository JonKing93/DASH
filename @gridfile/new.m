function[grid] = new(filename, metadata, overwrite)
%% gridfile.new  Create a new (empty) .grid file
% ----------
%   grid = gridfile.new(filename, metadata)
%   Initializes a new (empty) .grid file. The new file manages an
%   N-dimensional grid that spans the provided metadata. Adds a ".grid"
%   extension to the filename if it does not already have one.
%
%   grid = gridfile.new(filename, metadata, overwrite)
%   Specify whether the method may overwrite pre-existing .grid files. By
%   default, the method will not overwrite files.
% ----------
%   Inputs:
%       filename (string scalar): The name of the new .grid file. May be a
%           filename, relative path, or absolute path. If not an absolute
%           path, saves the new file relative to the current directory.
%       metadata (gridMetadata object): Metadata for the gridded dataset.
%       overwrite (scalar logical): Whether to overwrite existing files
%           (true) or not (false). Default is false.
%
%   Outputs:
%       grid (gridfile object): A gridfile object for the new .grid file.

% Default
if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = false;
end

% Error header
header = "DASH:gridfile:new";

% Error check
filename = dash.assert.strflag(filename, 'filename', header);
dash.assert.scalarType(metadata, 'gridMetadata', 'meta', header);
dash.assert.scalarType(overwrite, 'logical', 'overwrite', header);
filename = dash.file.new(filename, ".grid", overwrite, header);

% Get the dimensions and sizes
dims = metadata.defined;
nDims = numel(dims);
sizes = NaN(1, nDims);
for d = 1:nDims
    sizes(d) = size(metadata.(dims(d)), 1);
end

% Initialize deafult transformations
fill = NaN(0,1);
range = NaN(0,1);
transform = false;
transform_type = [];
transform_params = [];

% Initialize data sources
source = [];
relativePath = [];
dimLimit = [];
source_fill = [];
source_range = [];
source_transform = [];
source_transform_type = [];
source_transform_params = [];

% Save
save(filename, '-mat', ...
    'metadata', 'dims', 'sizes',...
    'fill','range','transform','transform_type','transform_params',...
    'source', 'relativePath', 'dimLimit',...
    'source_fill','source_range',...
    'source_transform','source_transform_type','source_transform_params'...
    );

% Get object
grid = gridfile(filename);

end