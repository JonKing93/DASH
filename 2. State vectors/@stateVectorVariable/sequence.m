function[obj] = sequence(obj, dim, indices, metadata)
%% Specifies to use a sequence of data for an ensemble dimension.
%
% obj = obj.sequence(dim, indices, metadata)
% Designs a sequence for a dimension and provides sequence metadata.
%
% ----- Inputs -----
%
% dim: The name of an ensemble dimension in the .grid file for the
%    variable. A string.
%
% indices: The sequence indices. A vector of integers that indicates the
%    position of sequence data-elements relative to the reference indices.
%    0 indicates the reference index. 1 is the data index following the
%    reference index. -1 is the data index before the reference index, etc.
%    Sequence indices may be in any order and cannot have a magnitude
%    larger than the length of the dimension in the .grid file.
%
% metadata: Metadata for the sequence. Either a vector with one element per
%    sequence index or an array with one row per sequence index.
%
% ----- Output -----
%
% obj: The updated stateVectorVariable object.

% Error check the dimension. Only ensemble dimensions are allowed
d = obj.checkDimensions(dim, false);
if obj.isState(d)
    error('Only ensemble dimensions can have mean indices, but %s (in variable %s) is a state dimension in variable %s. To make %s an ensemble dimension, see "stateVector.design".', obj.dims(d), obj.name, obj.name, obj.dims(d));
end

% Error check indices.
d = obj.checkEnsembleIndices(indices, d);

% Error check metadata
errorStrs = ['array', 'row'];
if isvector(metadata)
    errorStrs = ['vector', 'element'];
    metadata = metadata(:);
end
if size(metadata,1)~=numel(indices)
    error('When metadata is a %s, it must have one %s per sequence index (%.f), but metadata currently has %.f %ss.', errorStrs(1), errorStrs(2), numel(indices), size(metadata,1), errorStrs(2));
end

% Update
obj.size(d) = numel(indices);
obj.seqIndices{d} = indices;
obj.seqMetadata{d} = metadata;

end