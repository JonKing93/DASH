function[obj] = sequence(obj, varNames, dims, indices, metadata)
%% Use a sequence of data for ensemble dimensions in specified variables.
%
% obj = obj.sequence(varNames, dim, indices, metadata)
% Designs a sequence for an ensemble dimension and specifies sequence
% metadata.
%
% obj = obj.sequence(varNames, dims, indexCell, metadataCell)
% Designs a sequence and specifies metadata for multiple ensemble 
% dimensions.
%
% ----- Inputs -----
%
% varNames: The names of variables in the state vector for which to use a
%    sequence. A string vector or cellstring vector.
%
% dim: The name of an ensemble dimension in the .grid file for the
%    variables. A string.
%
% dims: The names of multiple ensemble dimensions. A string vector or
%    cellstring vector. May not repeat dimension names.
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
% metadata: Metadata for the sequence. Either a vector with one element per
%    sequence index or an array with one row per sequence index.
%
% metadataCell: A cell vector. Each element contains the metadata for one
%    dimension listed in dims. Must be in the stame dimension order as dims
%
% ----- Output -----
%
% obj: The updated stateVector object.

% Error check, variable index
v = obj.checkVariables(varNames);

% Update each variable
for k = 1:numel(v)
    obj.variables(v(k)) = obj.variables(v(k)).sequence(dims, indices, metadata);
end

end