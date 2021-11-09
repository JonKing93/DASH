function[] = expand(obj, dimension, metadata)
%% gridfile.expand  Increase the length of a dimension in a .grid file
% ----------
%   <strong>obj.expand</strong>(dimension, metadata)
%   Increases the length of a dimension. Appends new metadata values to
%   the existing metadata for the dimension. The number of rows in the new
%   metadata will determine the amount by which the dimension's length is
%   increased.
% ----------
%   Inputs:
%       dimension (string scalar): The name of the dimension whose length
%           should be increased. May be any recognized dimension name (See
%           gridMetadata.dimensions for a list of recognized dimensions)
%       metadata (matrix, numeric | logical | char | string | cellstring | datetime):
%           The metadata values that should be appended to the dimension.
%           Each row is one new element along the dimension. Cellstring
%           metadata will be converted to string.
%
%           If the dimension already exists in the .grid file,
%           metadata must have one column per column in the existing
%           metadata. The new metadata must also have a data type that can
%           be appended to the existing metadata. Compatible data types are
%           (numeric/logical), (char/string/cellstring), and (datetime).
%
% <a href="matlab:dash.doc('gridfile.expand')">Documentation Page</a>

% Setup
obj.update;
header = "DASH:gridfile:expand";

% Require defined dimension, do not include attributes
dim = dash.assert.strflag(dimension, 'dimension', header);
dimsName = sprintf('dimension in gridfile "%s"', obj.name);
d = dash.assert.strsInList(dim, obj.dims, 'dimension', dimsName, header);

% Get the existing metadata and metadata field sizes
oldMeta = obj.meta.(dim);
nOldCols = size(oldMeta,2);
[nNewRows, nNewCols] = size(metadata);

% Test data types
typeTest = {@isnumeric, @islogical, @ischar, @isstring, @iscellstr, @isdatetime};
nTypes = numel(typeTest);
types = false(nTypes, 2);
for t = 1:nTypes
    types(t,1) = typeTest{t}(oldMeta);
    types(t,2) = typeTest{t}(metadata);
end

% Check that types are compatible
if ( any(types(1:2,1)) && ~any(types(1:2,2)) ) || ...  % numeric / logical
   ( any(types(3:5:1)) && ~any(types(3:5,2)) ) || ...  % char / string / cellstring
   (types(6,1) && ~types(6,2))                         % datetime

    typeError(dim, types, obj.name, header);

% Check columns match
elseif nNewCols ~= nOldCols
    id = sprintf('%s:wrongNumberOfColumns', header);
    error(id, ['The number of columns in the new "%s" metadata (%.f) ',...
        'does not match the number of columns in the existing metadata ',...
        'for the dimension (%.f) in gridfile "%s".'], dim, nNewCols, nOldCols, obj.name);
end

% Attempt to concatenate.
try
    metadata = cat(1, oldMeta, metadata);
catch
    id = sprintf('%s:couldNotAppend', header);
    error(id, ['Could not append the new "%s" metadata to the existing ',...
        'metadata in gridfile "%s".'], dim, obj.name);
end

% Error check / update metadata. Also update sizes
obj.meta = obj.meta.edit(dim, metadata);
obj.size(d) = obj.size(d) + nNewRows;

% Save
obj.save;

end