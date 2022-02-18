function[obj] = trim(obj)
%% dash.stateVectorVariable.trim  Trim reference indices to only allow complete sequences and means.
% ----------
%   obj = <strong>obj.trim</strong>
%   Remove reference indices that would result in an ensemble member with
%   an incomplete sequence or incomplete mean.
%
%   **Note**: This method can only be called after the variable has been
%   finalized.
% ----------
%   Outputs:
%       obj (scalar dash.stateVectorVariable object): The state vector
%           variable with updated reference indices.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.trim')">Documentation Page</a>

% Cycle through ensemble dimensions
dims = find(~obj.isState);
for k = 1:numel(dims)
    d = dims(k);

    % Get maximum and minimum add indices
    addIndices = obj.addIndices(d);
    maxAdd = max(addIndices);
    maxSubtract = min(addIndices);

    % Find reference indices that would include elements that precede or
    % exceed the dimension's limits
    precede = (obj.indices{d} + maxSubtract) < 1;
    exceed = (obj.indices{d} + maxAdd) > obj.gridSize(d);
    remove = precede | exceed;

    % Remove the indices. Update size and alternate metadata
    obj.indices{d}(remove) = [];
    obj.ensSize(d) = numel(obj.indices{d});
    if obj.metadataType(d)==1
        obj.metadata_{d}(remove,:) = [];
    end
end

end