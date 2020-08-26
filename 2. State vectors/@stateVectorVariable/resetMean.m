function[obj] = resetMean(obj)
%% Resets specifications for means for a stateVectorVariable
%
% obj = obj.resetMean;
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

nDims = numel(obj.dims);
obj.takeMean = false(1, nDims);
obj.weightCell = cell(1, nDims);
obj.weightArray = [];
obj.nWeights = NaN(1, nDims);
obj.omitnan = false(1, nDims);

end