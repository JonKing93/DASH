function[obj] = sequence(obj, varName, dim, indices, metadata)
%% Specifies to use a sequence of data for an ensemble dimension.
%
% obj = obj.sequence(varName, dim, seq, metadata)
% Designs a sequence for a dimension of a state vector variable and
% provides sequence metadata.
%
% ----- Inputs -----
%
% varName: The name of a variable in the state vector. A string
%
% dim: The name of a dimension in the .grid file for the variable. A string
%
% indices: The sequence indices. A vector of integers that indicates the
%    position of sequence data relative to the reference indices. 0
%    indicates the reference index. 1 is the data index following the
%    reference index. -1 is the data index before the reference index, etc.
%
% metadata: Metadata for the sequence. A matrix with one row per sequence
%    element. May be any data type.
%
% ----- Output -----
%
% obj: The updated stateVector object.

% Error check the variable, get its index, update
v = obj.checkVariables(varName, false);
obj.variables(v) = obj.variables(v).sequence(dim, indices, metadata);

end