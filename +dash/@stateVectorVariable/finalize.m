function[obj] = finalize(obj)
%% dash.stateVectorVariable.finalize  Fill empty and placeholder values in a state vector variable
% ----------
%   obj = obj.finalize
%   Fills empty state / reference indices with values. If a dimension has
%   no means, sets the mean size to 1. Set mean and sequence indices to 0
%   in ensemble dimensions that lack these indices.
% ----------
%   Outputs:
%       obj (scalar dash.stateVectorVariable object): The variable updated
%           with finalized values
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.finalize')">Documentation Page</a>

% Cycle through dimensions. Select all gridfile indices if empty
for d = 1:numel(obj.dims)
    if isempty(obj.indices{d})
        obj.indices{d} = (1:obj.gridSize(d))';
    end

    % Fill empty mean size
    if obj.meanType(d)==0
        obj.meanSize(d) = 1;
    end

    % Fill empty mean/sequence indices for ensemble dimensions
    if ~obj.isState(d)
        if obj.meanType(d)==0
            obj.meanIndices{d} = 0;
        end
        if obj.hasSequence(d) = false;
            obj.sequenceIndices{d} = 0;
        end
    end
end

end