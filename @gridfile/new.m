function[obj] = new(filename, metadata, overwrite)
%% gridfile.new  Create a new, empty .grid file
% ----------
%   obj = gridfile.new(filename, metadata)
%   Initializes a new (empty) .grid file. The new file manages an
%   N-dimensional grid that spans the provided metadata. Adds a ".grid"
%   extension to the filename if it does not already have one.
%
%   obj = gridfile.new(..., overwrite)
%   obj = gridfile.new(..., true|"o"|"overwrite")
%   obj = gridfile.new(..., false|"p"|"preserve")
%   Specify whether the method may overwrite pre-existing .grid files. By
%   default, the method will not overwrite files.
% ----------
%   Inputs:
%       filename (string scalar): The name of the new .grid file. May be a
%           filename, relative path, or absolute path. If not an absolute
%           path, saves the new file relative to the current directory.
%       metadata (gridMetadata object): Metadata for the gridded dataset.
%           Metadata rows must be unique for each dimension.
%           If the metadata has a set dimension order, the order will be ignored.
%           The metadata object must have at least one dimension with
%           metadata (at least 1 defined dimension).
%       overwrite (scalar, logical | string): Whether to overwrite existing files
%           [true|"o"|"overwrite"]: Overwrite any existing file
%           [false|"p"|"preserve" (Default)]: Do not overwrite an existing file
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
flags = {["p","preserve"], ["o","overwrite"]};
overwrite = dash.parse.switches(overwrite, flags, 1, 'overwrite', "allowed option", header);
dash.assert.scalarType(overwrite, 'logical', 'overwrite', header);
filename = dash.assert.strflag(filename, 'filename', header);
filename = dash.file.new(filename, ".grid", overwrite, header);

dash.assert.scalarType(metadata, 'gridMetadata', 'metadata', header);
try
    metadata.assertUnique([], header);
catch ME
    throw(ME);
end
metadata = metadata.setOrder(0);
if numel(metadata.defined)==0
    id = sprintf('%s:metadataHasNoDimensions', header);
    error(id, ['The metadata has no dimensions. The gridMetadata object for a new ',...
        'gridfile must have at least 1 dimension with metadata.']);
end

% Initialize empty gridfile object
obj = gridfile;

% Set the metadata, dimensions, initialize dimLimit
obj.meta = metadata;
obj.dims = metadata.defined;
nDims = numel(obj.dims);
obj.dimLimit = NaN(nDims, 2, 0);

% Get dimension sizes
obj.size = NaN(1, nDims);
for d = 1:nDims
    dim = obj.dims(d);
    obj.size(d) = size(metadata.(dim), 1);
end

% Save the file. 
obj.file = filename;
obj.save;

% Update file name to absolute path and add to sources
obj.file = dash.assert.fileExists(obj.file);
obj.file = dash.file.urlSeparators(obj.file);
obj.sources_.gridfile = obj.file;

end