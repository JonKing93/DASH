function[obj] = resetMeans(obj)
%% Resets specifications for means for a stateVectorVariable
%
% obj = obj.resetMeans;
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% State size
nDims = numel(obj.dims);
stateMean = obj.isState & obj.takeMean;
obj.size(stateMean) = obj.meanSize(stateMean);

% Mean properties
obj.takeMean = false(1, nDims);
obj.meanSize = NaN(1, nDims);
obj.omitnan = false(1, nDims);
obj.mean_Indices = cell(1, nDims);

% Weighted means
obj.hasWeights = false(1, nDims);
obj.weightCell = cell(1, nDims);

end