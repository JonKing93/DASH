function[obj] = weightedMean(obj, dim, weights)
%% Use a weighted mean over a dimension
%
% obj = obj.weightedMean(dim, weights)
%
% ----- Inputs -----
%
% dim: The name of a dimension over which to take a weighted mean. A string
%
% weights: A numeric vector containing the weights. If dim is a state
%    dimension, weights are applied to each element in the state vector. If
%    dim is an ensemble dimension, applies weights to each element of the
%    mean indices. (See stateVector.info to summarize dimension
%    properties). May not contain NaN, Inf, or complex numbers.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% Error check, dimension index
d = obj.checkDimensions(dim, false);

% Update properties for state dimensions with no previous mean
if ~obj.takeMean(d) && obj.isState(d)
    obj = obj.mean(dim);
elseif ~obj.takeMean(d)
    error('No mean indices have been specified for ensemble dimension "%s" in variable %s. Use "stateVector.mean" to provide them.', dim, obj.name);
end

% Error check the weights
name = sprintf('weights for dimension "%s" of variable "s"', dim, obj.name);
dash.assertVectorTypeN(weights, 'numeric', obj.meanSize(d), name);
dash.assertRealDefined(weights, 'weights');

% Update
obj.hasWeights(d) = 1;
obj.weightCell{d} = weights(:);

end