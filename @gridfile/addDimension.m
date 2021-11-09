function[] = addDimension(obj, dimension, metadata)
%% gridfile.addDimension  Adds a new dimension to a .grid file
% ----------
%   obj.addDimension(dimension, metadata)

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