function[dimensions] = defined(obj)
%% gridMetadata.defined  Return a list of dimensions with defined metadata
% ----------
%   dimensions = <strong>obj.defined</strong>
%   Returns the list of dimensions that have metadata in the current
%   gridMetadata object. Does not include attributes.
% ----------
%   Outputs:
%       dimensions (string vector): A list of dimensions with metadata
%
% <a href="matlab:dash.doc('gridMetadata.defined')">Documentation Page</a>

dims = gridMetadata.dimensions;
nDims = numel(dims);
hasMetadata = false(nDims, 1);

for d = 1:nDims
    if ~isempty(obj.(dims(d)))
        hasMetadata(d) = true;
    end
end

dimensions = dims(hasMetadata);

end