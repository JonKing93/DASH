function[addIndex] = addIndices(obj, d)
%% Returns the add indices for a dimension. These are the mean indices
% propagated over the sequence elements
%
% addIndices = obj.addIndices(d)
%
% ----- Inputs -----
%
% d: The index of an ensemble dimension
%
% ----- Outputs -----
%
% addIndices: The add indices for the dimension as a column vector

% Get the mean indices
meanIndices = obj.meanIndices{d};
if isempty(meanIndices)
    meanIndices = 0;
end

% Propagate over the sequence indices. Convert to column
addIndex = meanIndices + obj.seqIndices{d}';
addIndex = addIndex(:);

end