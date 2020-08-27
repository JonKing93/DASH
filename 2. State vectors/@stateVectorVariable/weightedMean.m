function[obj] = weightedMean(obj, dims, weights)
%% Specify options for taking a weighted mean over dimensions.
%
% obj = obj.weightedMean(dim, weights)
% Takes a weighted mean over a dimension.
%
% obj = obj.weightedMean(dims, weightCell)
% obj = obj.weightedMean(dims, weightArray)
% Takes a weighted mean over multiple dimensions.
%
% ----- Inputs -----
%
% dim: The name of a dimension over which to take a weighted mean. A string
%
% weights: A numeric vector containing the mean weights. If dim is a state
%    dimension, must have a length equal to the number of state indices.
%    If dim is an ensemble dimension, the length must be equal to the
%    number of mean indices. (See stateVector.info to summarize dimension
%    properties). May not contain NaN, Inf, or complex numbers.
%
% weightCell: A cell vector. Each element contains mean weights for one
%    dimension listed in dims. Must be in the same order as dims.
%
% weightArray: An N-dimensional numeric array containing weights for taking
%    a mean across specified dimensions. Must have a dimension for each
%    dimension listed in dims and must have the same dimension order as
%    dims. The length of each dimension of weightArray must be equal to
%    either the number of state indices or mean indices, as appropriate.
%    (See the "weights" input for details). May not contain NaN, Inf, or
%    complex numbers.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% Error check, dimension index
d = obj.checkDimensions(dims, true);
nDims = numel(d);

% Error check the weights
if nDims==1
    dash.assertVectorTypeN(weights, 'numeric', obj.meanSize(d), name);
elseif iscell(weights)
    dash.assertVectorTypeN(weights, [], nDims, 'weightCell');
    








% Update properties for state dimensions with no previous mean
if ~obj.takeMean(d) && obj.isState(d)
    obj = obj.mean(dims);
elseif ~obj.takeMean(d)
    error('No mean indices have been specified for ensemble dimension "%s" in variable %s. Use "stateVector.mean" to provide them.', dims, obj.name);
end

% Error check the weights
name = sprintf('weights for dimension "%s" of variable "s"', dims, obj.name);
dash.assertVectorTypeN(weights, 'numeric', obj.meanSize(d), name);
dash.assertRealDefined(weights, 'weights');

% Update
obj.hasWeights(d) = true;
obj.weightCell{d} = weights(:);

end