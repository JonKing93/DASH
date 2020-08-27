function[obj] = resetMean(obj)
%% Resets specifications for means for a stateVectorVariable
%
% obj = obj.resetMean;
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% Size
nDims = numel(obj.dims);

% Mean properties
obj.takeMean = false(1, nDims);
obj.meanSize = NaN(1, nDims);
obj.omitnan = false(1, nDims);
obj.mean_Indices = cell(1, nDims);

% Weighted means
obj.hasWeights = zeros(1, nDims);
obj.weightCell = cell(1, nDims);
obj.weightArray = [];

end