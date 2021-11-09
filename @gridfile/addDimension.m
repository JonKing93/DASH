function[] = addDimension(obj, dimension, metadata)
%% gridfile.addDimension  Add a new dimension to a .grid file
% ----------
%   <strong>obj.addDimension</strong>(dimension, metadata)
%   Adds a new dimension and associated metadata to a gridfile. The new
%   dimension is treated as a trailing singleton dimensions in the existing
%   data grid. Consequently, the metadata for the new dimension must be a
%   row vector or scalar.
% ----------
%   Inputs:
%       dimension (string scalar): The name of a new dimension to add to
%           the gridfile. Must be a recognized grid dimension.
%           (See gridMetadata.dimensions for a list of recognzied
%           dimensions).
%       metadata (row vector, numeric | logical | char | string | cellstring | datetime):
%           metadata values for the new, singleton dimension. Cellstring
%           values will be converted to string.
%
% <a href="matlab:dash.doc('gridfile.addDimension')">Documentation Page</a>

% Setup
obj.update;
header = "DASH:gridfile:addDimension";

% Get valid dimension names, throw error if none are left
dims = gridMetadata.dimensions;
undefined = ~ismember(dims, obj.dims);
if ~any(undefined)
    noUndefinedDimensionsError;
end

% Check the dimension name is valid
dim = dash.assert.strflag(dimension, 'dimension', header);
undefined = dims(undefined);
if ismember(dim, obj.dims)
    dimensionExistsError;
end
dash.assert.strsInList(dim, undefined, 'dimension', 'a valid dimension', header);

% Metadata must have a single row
if size(metadata,1)~=1
    metadataRowError;
end

% Add the new dimension
obj.meta = obj.meta.edit(dim, metadata);
obj.dims = [obj.dims, dim];
obj.size = [obj.size, 1];

newRow = ones(1, 2, obj.nSource);
obj.dimLimit = cat(1, obj.dimLimit, newRow);

% Save
obj.save;

end