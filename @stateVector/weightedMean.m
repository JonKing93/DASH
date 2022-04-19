function[obj] = weightedMean(obj, variables, dimensions, weights)
%% stateVector.weightedMean  Take a weighted mean over dimensions of variables in a state vector
% ----------
%   obj = obj.weightedMean(0, ...)
%   obj = obj.weightedMean(v, ...)
%   obj = obj.weightedMean(variableNames, ...)
%   Updates weighted mean settings for the listed variables. If the first
%   input is zero, applies the settings to every variable currently in the
%   state vector.
%
%   obj = obj.weightedMean(variables, stateDimension, weights)
%   Takes a weighted mean over the indicated state dimension. You must
%   provide a weight for each state index along the dimension.
%
%   obj = obj.weightedMean(variables, ensembleDimension, weights)
%   Takes a weighted mean over the indicated ensemble dimension. Before
%   using this method, you must first use the "stateVector.mean" method
%   to provide mean indices for the ensemble dimension. You must provide a
%   weight for each mean index.
%
%   obj = obj.weightedMean(variables, dimensions, weights)
%   Take a weighted mean over multiple dimensions. If the dimension list
%   contains ensemble dimensions, you must have first called the
%   "stateVector.mean" method on the ensemble dimensions.
% ----------
%   Inputs:
%       v (logical vector | linear indices): The indices of variables in
%           the state vector over which to take a weighted mean. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If linear indices, may not contain repeated
%           indices.
%       variableNames (string vector): The names of variables in the state
%           vector over which to take a weighted mean. May not contain
%           repeated variable names.
%       dimensions (string vector [nDimensions]): The names of the dimensions
%           over which to take a weighted mean. Cannot have repeated dimension names.
%       weights (cell vector [nDimensions] {[] | numeric vector}): The weights
%           to use for the weighted mean. A cell vector with one element
%           per listed dimension. Each should holds the weights for the
%           corresponding dimension. Weights must either be an empty array,
%           or a numeric vector that does not contain contain NaN, Inf, or
%           complex-valued elements. 
% 
%           If weights is an empty array, an unweighted mean will be taken for the
%           dimension. Otherwise, the weights for a state dimension should
%           have one element per state index. The weights for an ensemble
%           dimension should have one element per mean index.
%   
%           If only a single dimension is listed, you may provide the
%           sequence indices directly as a vector, instead of in a scalar
%           cell. However, the scalar cell syntax is also permitted.
% 
%   Outputs:
%       obj (scalar stateVector object): The state vector updated with the
%           weighted mean options.
%
% <a href="matlab:dash.doc('stateVector.weightedMean')">Documentation Page</a>

% Setup
header = "DASH:stateVector:weightedMean";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Error check dimensions and variables, get indices
if isequal(variables, 0)
    v = 1:obj.nVariables;
else
    v = obj.variableIndices(variables, false, header);
end
[d, dimensions] = obj.dimensionIndices(v, dimensions, header);
nDims = numel(dimensions);

% Error check weights
weights = dash.parse.inputOrCell(weights, nDims, 'weights', header);
for k = 1:nDims
    name = dash.string.elementName(k, 'Mean weights', nDims);
    if ~isempty(weights{k})
        dash.assert.vectorTypeN(weights{k}, 'numeric', [], name, header);
        dash.assert.defined(weights{k}, 1, name, header);
    end
end

% Update the variables
method = 'weightedMean';
inputs = {weights};
task = 'take a weighted mean over';
obj = obj.editVariables(v, d, method, inputs, task);
obj = obj.updateLengths(v);

end