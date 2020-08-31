function[obj] = weightedMean(obj, varNames, dims, weights)
%% Specify options for taking a weighted mean over dimensions of specified variables.
%
% obj = obj.weightedMean(varNames, dim, weights)
% Takes a weighted mean over a dimension.
%
% obj = obj.weightedMean(varNames, dims, weightCell)
% obj = obj.weightedMean(varNames, dims, weightArray)
% Takes a weighted mean over multiple dimensions.
%
% ----- Inputs -----
%
% varNames: The names of the variables over which to take a mean. A string
%    vector or cellstring vector.
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
% obj: The updated stateVector object

% Error check, variable index
v = obj.checkVariables(varNames);

% Update each variable
for k = 1:numel(v)
    obj.variables(v(k)) = obj.variables(v(k)).weightedMean(dims, weights);
end

end