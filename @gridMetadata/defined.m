function[dimensions, sizes] = defined(obj)
%% gridMetadata.defined  Return a list of dimensions with defined metadata
% ----------
%   dimensions = <strong>obj.defined</strong>
%   Returns the list of dimensions that have metadata in the current
%   gridMetadata object. Does not include attributes.
%
%   [dimensions, size] = <strong>obj.defined</strong>
%   Also returns the sizes of the defined dimensions. The size of a
%   dimension is the number of rows in its metadata.
% ----------
%   Outputs:
%       dimensions (string vector): A list of dimensions with metadata
%       size (vector, positive integers): The number of metadata rows for
%           each defined dimension.
%
% <a href="matlab:dash.doc('gridMetadata.defined')">Documentation Page</a>

% Setup
header = "DASH:gridMetadata:defined";
dash.assert.scalarObj(obj, header);

% Get dimensions and preallocate
dims = gridMetadata.dimensions;
nDims = numel(dims);
hasMetadata = false(1, nDims);
sizes = NaN(1, nDims);

% Check for metadata and size
for d = 1:nDims
    meta = obj.(dims(d));
    if ~isempty(meta)
        hasMetadata(d) = true;
        sizes(d) = size(meta,1);
    end
end

% Get the dimensions and sizes
dimensions = dims(hasMetadata)';
sizes = sizes(hasMetadata);

end