function[obj] = sequence(obj, variables, dimensions, indices, metadata)
%% stateVector.sequence  Use a sequence of data along ensemble dimensions
% ----------
%   obj = obj.sequence(0, ...)
%   obj = obj.sequence(v, ...)
%   obj = obj.sequence(variableNames, ...)
%   Creates sequences for the listed variables. If the first input is 0,
%   applies a sequence to every variable currently in the state vector.
% 
%   obj = obj.sequence(variables, dimensions, indices, metadata)
%   Design sequences for the listed ensemble dimensions.
%   Sequences are built using the provided sequence indices. Each set of
%   sequence indices is associated with a provided set of metadata.
% ----------
%   Inputs:
%       v (logical vector | linear indices): The indices of variables in
%           the state vector that should be given a sequence. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If linear indices, may not contain repeated
%           indices.
%       variableNames (string vector): The names of variables in the state
%           vector that should be given a sequence. May not contain
%           repeated variable names.
%       dimensions (string vector): The names of the ensemble dimensions
%           that should be given a sequence. Each dimension must be an
%           ensemble dimension in all listed variables. Cannot have
%           repeated dimension names.
%       indices (cell vector [nDimensions] {sequence indices | []}): The
%           sequence indices to use for each dimension. Sequence indices
%           how to select state vector elements along ensemble dimensions.
%           For each ensemble member, the sequence indices are added to the
%           reference index, and the resulting elements are used as state
%           vector rows. If the ensemble dimension also uses a mean, the
%           mean indices are applied at each sequence element.
%
%           indices should be a cell vector with one element per listed
%           dimension. Each element contains the sequence indices for the
%           corresponding dimension or an empty array. Sequence indices are
%           0-indexed from the reference element for each ensemble member 
%           and may include negative values. If an element of indices contains
%           an empty array, then any pre-existing sequences are removed for 
%           that dimension. The sequence metadata for that dimension must also be
%           an empty array.
%
%           If only a single dimension is listed, you may provide the
%           sequence indices directly as a vector, instead of in a scalar cell.
%           However, the scalar cell syntax is also permitted.
%       metadata (cell vector [nDimensions] {metadata matrix [nSequenceIndices x ?]}):
%           Sequence metadata for each listed dimension. Sequence metadata
%           is used as the unique metadata marker for each sequence element
%           along the state vector.
%
%           metadata should be a cell vector with one element per listed
%           dimension. Each element holds the sequence metadata for the
%           correpsonding dimension. Each set of metadata must be a matrix
%           with one row per associated sequence index. Each metadata
%           matrix should have unique rows.
% 
%           Metadata matrices may have a numeric, logical, char, string, 
%           cellstring, or datetime data type. They cannot contain NaN or NaT 
%           elements. Cellstring metadata will be converted to string. If there
%           are no sequence indices for a dimension, then the sequence metadata
%           for the dimension should be an empty array. 
%
%           If only a single dimension is listed, you may provide sequence
%           metadata directly as a matrix, instead of in a scalar cell. However,
%           the scalar cell syntax is also permitted.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector updated with the
%           new sequence parameters.
%
% <a href="matlab:dash.doc('stateVector.sequence')">Documentation Page</a>

% Setup
header = "DASH:stateVector:sequence";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Error check variables and dimensions. Get indices
if isequal(variables, 0)
    v = 1:obj.nVariables;
else
    v = obj.variableIndices(variables, false, header);
end
[d, dimensions] = obj.dimensionIndices(v, dimensions, header);
nDims = numel(dimensions);

% Error check indices
indices = dash.assert.additiveIndexCollection(indices, nDims, dimensions, header);

% Check metadata is valid and unique. Convert cellstring
metadata = dash.parse.inputOrCell(metadata, nDims, "metadata", header);
for k = 1:nDims
    meta = gridMetadata(dimensions(k), metadata{k});
    meta.assertUnique(dimensions(k), header);
    metadata{k} = meta.(dimensions(k));

    % Check metadata matches the number of sequence indices
    nRows = size(metadata{k},1);
    nIndices = numel(indices{k});
    if nRows ~= nIndices
        metadataSizeConflictError(nRows, nIndices, dimensions(k), header);
    end
end

% Update the variables
method = 'sequence';
inputs = {indices, metadata, header};
task = 'design a sequence for';
obj = obj.editVariables(v, d, method, inputs, task);
obj = obj.updateLengths(v);

end

% Error message
function[] = metadataSizeConflictError(nRows, nIndices, dimension, header)
id = sprintf('%s:metadataWrongSize', header);
ME = MException(id, ['The number of rows in the sequence metadata for the "%s" dimension ',...
    '(%.f) does not match the number of sequence indices for the dimension (%.f).'],...
    dimension, nRows, nIndices);
throwAsCaller(ME);
end
