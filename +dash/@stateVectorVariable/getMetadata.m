function[metadata] = getMetadata(obj, d, grid, header)
%% Returns the metadata for a dimension of a state vector variable

% Use alternate metadata directly
if obj.metadataType(d) == 1
    metadata = obj.metadata{d};
    return;
end

% Build gridfile if not provided
if dash.is.strflag(grid)
    grid = gridfile(grid);
    obj.validateGrid(grid);
end

% Extract metadata from gridfile
dim = obj.dims(d);
metadata = grid.metadata.(dim)(obj.indices{d}, :);

% Finished if using raw metadata
if obj.metadataType(d) == 0
    return;
end

% Run the conversion function
try
    metadata = obj.convertFunction{d}(metadata, obj.convertArgs{d}{:});
catch
    failedConversionError(header);
end

% Check that converted metadata is a valid metadata matrix
try
    metadata = gridMetadata(dim, metadata);
    metadata.assertUnique(dim, header);
    metadata = metadata.(dim);
catch
    invalidConversionError(header);
end

% Check the number of rows match the ensemble size
nRows = size(metadata, 1);
if nRows ~= obj.ensSize(d)
    metadataSizeConflictError(header);
end

end