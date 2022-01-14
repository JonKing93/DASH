function[obj] = ensembleDimension(obj, d, indices)
%% dash.stateVectorVariable.ensembleDimension  Designs an ensemble dimension
% ----------
%   obj = <strong>obj.ensembleDimension</strong>(d, indices)
%   Converts a dimension of a state vector variable to an ensemble dimension.
% ----------
%   Inputs:
%       d (scalar positive integer): The index of a dimension in the variable
%       indices (vector, linear indices | []): The reference indices for the variable
%
%   Outputs:
%       obj (scalar stateVectorVariable): The updated variable
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.ensembleDimension')">Documentation Page</a>

% If converting from a state dimension, initialize sequence properties
if obj.isState(d)
    obj.sequenceIndices{d} = 0;
    obj.sequenceMetadata{d} = NaN;
end

% Update indices and sizes
obj.indices{d} = indices;
obj.stateSize(d) = numel(obj.sequenceIndices{d});

obj.ensSize(d) = obj.gridSize(d);
if ~isempty(indices)
    obj.ensSize(d) = numel(indices);
end

end