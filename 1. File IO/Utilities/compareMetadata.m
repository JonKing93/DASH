function[] = compareMetadata( meta, m, field, indices )
% Compares user-specified metadata to metadata in a .grid file at specific
% indices.
%
% compareMetadata( meta, m, field, indices )

% Load the grid metadata
gridMeta = m.meta;

% Check that the grid metadata has values for the correct dimension'
if ~isfield(gridMeta, field)
    error('The metadata in the .grid file does not contain values for the %s dimension.', field);
end

% Get the values for the correct dimension
gridMeta = gridMeta.(field);

% Restrict to the indices
gridMeta = gridMeta( indices, : );

% If the metadata is a row vector with exactly the number of indices, convert to column.
if isrow(meta) && length(meta)==numel(indices)
    meta = meta';
end

% Compare the metadata. Treat NaN as equivalent.
if ~isequaln( meta, gridMeta )
    error('The provided metadata values do not match the metadata values in the .grid file at the specified indices.');
end

end