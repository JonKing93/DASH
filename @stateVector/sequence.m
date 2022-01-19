function[obj] = sequence(obj, variables, dimensions, indices, metadata)
%% stateVector.sequence  Use a sequence of data along ensemble dimensions
% ----------
%   obj = obj.sequence(v, dimensions, indices, metadata)
%   obj = obj.sequence(variableNames, dimensions, indices, metadata)
%   Designs a sequence for ensemble dimensions in the indicated variables.
%   Sequences are built using the provided sequence indices. Each set of
%   sequence indices are associated with a provided set of metadata.
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
%       dimensions (string vector): The names of the ensemble dimmensions
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
%           and may include negative values. The magnitude of sequence
%           indices may not exceed the length of the associated dimension.
%           If an element of indices contains an empty array, then any
%           pre-existing sequences are removed for that dimension. Sequence
%           metadata for the metadata must also be an empty array.
%
%           If only a single dimension is listed, you may provide the
%           sequence indices directly, instead of in a scalar cell.
%           However, the scalar cell syntax is also permitted.
%       metadata (cell vector [nDimensions] {matrix, numeric | logical | char | string | cellstring | datetime | []}):
%           Sequence metadata for each listed dimension. Sequence metadata
%           is used as the unique metadata marker for each sequence element
%           along the state vector.
%
%           metadata should be a cell vector with one element per listed
%           dimension. Each element holds the sequence metadata for the
%           correpsonding dimension. Each set of metadata must be a matrix
%           with one row per associated sequence index. Metadata cannot
%           include NaN or NaT elements. If there are no sequence indices
%           for a dimension, then the sequence metadata for the dimension
%           should be an empty array.
%
%           If only a single dimension is listed, you may provide sequence
%           metadata directly, instead of in a scalar cell. However, the
%           scalar cell syntax is also permitted.
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

% Error check variables and get indices
vars = obj.variableIndices(variables, false, header);

% Error check dimensions
dimensions = dash.assert.strlist(dimensions);
dash.assert.uniqueSet(dimensions, 'dimensions', header);
nDims = numel(dimensions);

% Error check 