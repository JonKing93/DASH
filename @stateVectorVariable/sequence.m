function[obj] = sequence(obj, dims, indices, metadata)
%% Specifies to use a sequence of data for ensemble dimensions.
%
% obj = obj.sequence(dim, indices, metadata)
% Designs a sequence for an ensemble dimension and specifies sequence
% metadata.
%
% obj = obj.sequence(dims, indexCell, metadataCell)
% Designs a sequence and specifies metadata for multiple ensemble 
% dimensions.
%
% ----- Inputs -----
%
% dim(s): The name(s) of ensemble dimension(s) in the .grid file for the
%    variable. A string vector, cellstring vector, or character row vector.
%    May not repeat dimension names.
%
% indices: The sequence indices. A vector of integers that indicates the
%    position of sequence data-elements relative to the reference indices.
%    0 indicates the reference index. 1 is the data index following the
%    reference index. -1 is the data index before the reference index, etc.
%    Sequence indices may be in any order and cannot have a magnitude
%    larger than the length of the dimension in the .grid file.
%
% indexCell: A cell vector. Each element contains the sequence indices for
%    one dimension listed in dims. Must be in the same dimension order as
%    dims.
%
% metadata: Metadata for the sequence. An array with one row per sequence index.
%
% metadataCell: A cell vector. Each element contains the metadata for one
%    dimension listed in dims. Must be in the same dimension order as dims
%
% ----- Output -----
%
% obj: The updated stateVectorVariable object.

% Error check the dimensions. Only ensemble dimensions are allowed
[d, dims] = obj.checkDimensions(dims);
if any(obj.isState(d))
    bad = d(find(obj.isState(d),1));
    stateDimensionError(obj, bad);
end
nDims = numel(d);

% Parse indices and metadata. Error check cell vectors
[indices, wasCell] = dash.parse.inputOrCell(indices, nDims, 'indexCell');
metadata = dash.parse.inputOrCell(metadata, nDims, 'metadataCell');

% Error check indices for each dimension
name = 'indices';
for k = 1:nDims
    if wasCell
        name = sprintf('Element %.f of indexCell', k);
    end
    obj.assertAddIndices(indices{k}, d(k), name);
    
    % Check metadata is allowed type. Convert cellstring to string
    metadata{k} = dash.assert.metadataField(metadata{k}, dims(k));
    
    % Metadata rows
    if size(metadata{k},1)~=numel(indices{k})
        metadataSizeError( obj, dims(k), numel(indices{k}), size(metadata{k},1) );
    end

    % Update
    obj.stateSize(d(k)) = numel(indices{k});
    obj.seqIndices{d(k)} = indices{k}(:);
    obj.seqMetadata{d(k)} = metadata{k};
end

end

% Long error messages
function[] = stateDimensionError(obj, bad)
error(['Only ensemble dimensions can have sequence indices, but %s ', ...
    'is a state dimension in variable %s. To make %s an ',...
    'ensemble dimension, see "stateVector.design".'], obj.dims(bad), ...
    obj.name, obj.dims(bad));
end
function[] = metadataSizeError(obj, dim, nIndex, nRows)
error(['Sequence metadata must have one row per sequence index (%.f), ',...
    'but the metadata for dimension "%s" in variable "%s" currently has %.f rows.'], ...
    nIndex, dim, obj.name, nRows);
end