function[obj] = sequence(obj, dim, indices, metadata)
%% Specifies to use a sequence of data for an ensemble dimension.
%
% obj = obj.sequence(dim, indices, metadata)
% Designs a sequence for a dimension and provides sequence metadata.
%
% ----- Inputs -----
%
% dim: The name of a dimension in the .grid file for the variable. A string
%
% indices: The sequence indices. A vector of integers that indicates the
%    position of sequence data relative to the reference indices. 0
%    indicates the reference index. 1 is the data index following the
%    reference index. -1 is the data index before the reference index, etc.
%    Sequence indices may be in any order and cannot have a magnitude
%    larger than the length of the dimension.
%
% metadata: Metadata for the sequence. A numeric, logical,
%    char, string, cellstring, or datetime matrix. Each row is treated
%    as the metadata for one dimension element. Each row must be unique
%    and cannot contain NaN, Inf, or NaT elements. Cellstring metadata
%    will be converted into the "string" type.
%
% ----- Output -----
%
% obj: The updated stateVectorVariable object.

% Error check the dimension. Only ensemble dimensions are allowed
d = obj.checkDimensions(dim, false);
if obj.isState(d)
    error('Only ensemble dimensions can have sequences, but %s is a state dimension in variable %s. To make %s an ensemble dimension, see stateVector.design.', obj.dims(d), obj.name, obj.dims(d));
end

% Error check indices and metadata
dash.assertVectorTypeN(indices, 'numeric', [], 'indices');
if any(mod(indices,1)~=0)
    error('"indices" must be a vector of integers.');
elseif any(abs(indices)>obj.gridSize(d))
    bad = find(abs(indices)>obj.gridSize(d),1);
    error('Element %.f of indices (%.f) has a magnitude larger than the length of the %s dimension (%.f).', bad, indices(bad), obj.dims(d), obj.gridSize(d));
end

% Error check metadata
dash.checkMetadataField(metadata, obj.dims(d));
if size(metadata,1)~=numel(indices)
    error('metadata must have one row per sequence index (%.f) but currently has %.f rows.', numel(indices), size(metadata,1));
end

% Update
obj.size(d) = numel(indices);
obj.seqIndices{d} = indices;
obj.seqMetadata{d} = metadata;

end