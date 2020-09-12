function[obj] = resetMeans(obj, dims)
%% Resets specifications for means for a stateVectorVariable
%
% obj = obj.resetMeans
% Resets metadata optiosn for all dimensions
%
% obj = obj.resetMetadata(dims)
% Resets metadata options for specified dimensions
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% Default for no dims
if ~exist('dims','var') || isempty(dims)
    d = 1:numel(obj.dims);
else
    d = obj.checkDimensions(dims);
end
nDims = numel(d);

% State size
stateMean = obj.isState(d) & obj.takeMean(d);
obj.stateSize(stateMean) = obj.meanSize(stateMean);

% Mean properties
obj.takeMean(d) = false;
obj.meanSize(d) = NaN;
obj.omitnan(d) = false;
obj.mean_Indices(d) = cell(1, nDims);

% Weighted means
obj.hasWeights(d) = false;
obj.weightCell(d) = cell(1, nDims);

end