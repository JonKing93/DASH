function[obj] = new(filename, metadata, overwrite)
%% gridfile.new  Create a new (empty) .grid file
% ----------
%   obj = gridfile.new(filename, metadata)
%   Initializes a new (empty) .grid file. The new file manages an
%   N-dimensional grid that spans the provided metadata. Adds a ".grid"
%   extension to the filename if it does not already have one.
%
%   obj = gridfile.new(filename, metadata, overwrite)
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
%       obj (gridfile object): A gridfile object for the new .grid file.
%
% <a href="matlab:dash.doc('gridfile.new')">Documentation Page</a>

% Default
if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = false;
end

% Error header
header = "DASH:gridfile:new";

% Error check
filename = dash.assert.strflag(filename, 'filename', header);
dash.assert.scalarType(metadata, 'gridMetadata', 'metadata', header);
metadata.assertUnique(header);
dash.assert.scalarType(overwrite, 'logical', 'overwrite', header);
filename = dash.file.new(filename, ".grid", overwrite, header);

% Initialize empty gridfile object
obj = gridfile;

% Set the metadata, dimensions, initialize dimLimit
obj.meta = metadata;
obj.dims = metadata.defined';
nDims = numel(obj.dims);
obj.dimLimit = NaN(nDims, 2, 0);

% Get dimension sizes
obj.size = NaN(1, nDims);
for d = 1:nDims
    dim = obj.dims(d);
    obj.size(d) = size(metadata.(dim), 1);
end

% Save the file. Update file name to absolute path and add to sources
obj.file = filename;
obj.save;
obj.file = dash.assert.fileExists(obj.file);
obj.sources_.gridfile = obj.file;

end