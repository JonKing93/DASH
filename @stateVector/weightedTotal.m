function[obj] = weightedTotal(obj, variables, dimensions, weights)
%% stateVector.weightedTotal  Take a weighted total over dimensions of variables in a state vector
% ----------
%   obj = <strong>obj.weightedTotal</strong>(-1, ...)
%   obj = <strong>obj.weightedTotal</strong>(v, ...)
%   obj = <strong>obj.weightedTotal</strong>(variableNames, ...)
%   Updates weighted total settings for the listed variables. If the first
%   input is -1, applies the settings to every variable currently in the
%   state vector.
%
%   obj = <strong>obj.weightedTotal</strong>(variables, stateDimension, weights)
%   Takes a weighted total over the indicated state dimension. You must
%   provide a weight for each state index along the dimension.
%
%   obj = <strong>obj.weightedTotal</strong>(variables, ensembleDimension, weights)
%   Takes a weighted total over the indicated ensemble dimension. Before
%   using this method, you must first use the "stateVector.total" method
%   to provide total indices for the ensemble dimension. You must provide a
%   weight for each total index.
%
%   obj = <strong>obj.weightedTotal</strong>(variables, dimensions, weights)
%   Take a weighted total over multiple dimensions. If the dimension list
%   contains ensemble dimensions, you must have first called the
%   "stateVector.total" method on the ensemble dimensions.
% ----------
%   Inputs:
%       v (logical vector | linear indices | -1): The indices of variables in
%           the state vector over which to take a weighted total. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If linear indices, may not contain repeated
%           indices. If -1, applies the settings to all variables in the
%           state vector.
%       variableNames (string vector): The names of variables in the state
%           vector over which to take a weighted total. May not contain
%           repeated variable names.
%       dimensions (string vector [nDimensions]): The names of the dimensions
%           over which to take a weighted total. Cannot have repeated dimension names.
%       weights (cell vector [nDimensions] {[] | numeric vector}): The weights
%           to use for the weighted total. A cell vector with one element
%           per listed dimension. Each should holds the weights for the
%           corresponding dimension. Weights must either be an empty array,
%           or a numeric vector that does not contain contain NaN, Inf, or
%           complex-valued elements. 
% 
%           If weights is an empty array, an unweighted total will be taken for the
%           dimension. Otherwise, the weights for a state dimension should
%           have one element per state index. The weights for an ensemble
%           dimension should have one element per total index.
%   
%           If only a single dimension is listed, you may provide the
%           sequence indices directly as a vector, instead of in a scalar
%           cell. However, the scalar cell syntax is also permitted.
% 
%   Outputs:
%       obj (scalar stateVector object): The state vector updated with the
%           weighted total options.
%
% <a href="matlab:dash.doc('stateVector.weightedTotal')">Documentation Page</a>

% Setup
header = "DASH:stateVector:weightedTotal";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Error check dimensions and variables, get indices
v = obj.variableIndices(variables, false, header);
[d, dimensions] = obj.dimensionIndices(v, dimensions, header);
nDims = numel(dimensions);

% Error check weights
weights = dash.parse.inputOrCell(weights, nDims, 'weights', header);
for k = 1:nDims
    name = dash.string.elementName(k, 'Total weights', nDims);
    if ~isempty(weights{k})
        dash.assert.vectorTypeN(weights{k}, 'numeric', [], name, header);
        dash.assert.defined(weights{k}, 1, name, header);
    end
end

% Update the variables
method = 'weightedTotal';
inputs = {weights, header};
task = 'take a weighted total over';
obj = obj.editVariables(v, d, method, inputs, task);
obj = obj.updateLengths(v);

end