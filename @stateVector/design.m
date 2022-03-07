function[obj] = design(obj, variables, dimensions, indices, types)
%% stateVector.design  Design the dimensions of variables in a state vector
% ----------
%   obj = obj.design(v, dimensions, indices)
%   obj = obj.design(variableNames, dimensions, indices)
%   Specifies state and/or reference indices for the indicated dimensions.
%   Indices for state dimensions (state indices) indicate which elements
%   along the dimension should be used in the state vector. Indices for
%   ensemble dimensions (reference indices) are used to select ensemble
%   members.
%
%   obj = obj.design(..., types)
%   obj = obj.design(..., 0|"c"|"current")
%   obj = obj.design(..., 1|"s"|"state")
%   obj = obj.design(..., 2|"e"|"ens"|"ensemble")
%   Specify that the indicated dimensions should be used as state
%   dimensions, ensemble dimensions, or kept in their current state.
%   If a single option is provided, applies the same setting to all input
%   dimensions. Provide multiple types to select different settings for
%   different dimensions.
% ----------
%   Inputs:
%       v (logical vector | linear indices): The indices of variables in
%           the state vector that should be designed. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If linear indices, may not contain repeated
%           indices.
%       variableNames (string vector): The names of variables in the state
%           vector whose dimensions should be designed. May not contain
%           repeated variable names.
%       dimensions (string vector [nDimensions]): The names of dimensions
%           that should be designed. Each dimension must occur in all
%           listed variables. Cannot have repeated dimension names.
%       indices (cell vector [nDimensions] {[] | logical vector [dimension length] | vector, linear indices}):
%           State and reference indices for the designed dimensions. State
%           indices are used for state dimensions; they indicate which
%           elements along the dimension should be included in the state
%           vector. Reference indices are used for ensemble dimensions;
%           they indicate the elements along the dimension that can be used
%           as reference elements for ensemble members.% 
% 
%           In most cases, indices should be a vector with a set of indices
%           for each listed dimension. Each set of indices must either be a
%           logical vector the length of the dimension, a set of linear
%           indices, or an empty array. If the indices for a dimension are
%           an empty array, selects all elements along the dimension as
%           state/reference dimensions. If indices are linear indices, they
%           cannot contain repeat elements.
%
%           If only a single dimension is listed, the dimension's indices
%           may be provided directly as a vector, instead of in a scalar cell.
%           However, the scalar cell syntax is also permitted.
%       types (vector [1 | nDimensions], string | integer): The type of
%           each dimension. Options are:
%           [0|"c"|"current"]: (default) Leave in current state
%           [1|"s"|"state"]: State dimension
%           [2|"e"|"ens"|"ensemble"]: Ensemble dimension
%
%           If types is scalar, uses the same setting for all indicated
%           dimensions. Otherwise, types must have one element per listed
%           dimension.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector updated with the
%           designed variables and dimensions.
%
% <a href="matlab:dash.doc('stateVector.design')">Documentation Page</a>

% Setup
header = "DASH:stateVector:design";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Error check variables and dimensions. Get indices.
v = obj.variableIndices(variables, false, header);
[d, dimensions] = obj.dimensionIndices(v, dimensions, header);
nDims = numel(dimensions);

% Parse dimension types
options = {["c","current"], ["s","state"], ["e","ens","ensemble"]};
types = dash.parse.switches(types, options, nDims, ...
                    'Dimension type', 'recognized dimension type', header);
if numel(types)==1
    isstate = repmat(types, [1 nDims]);
end

% Parse indices
if ~exist('indices','var')
    indices = cell(1, nDims);
else
    indices = dash.assert.indexCollection(indices, nDims, [], dimensions, header);
end

% Require unique state/reference indices
for k = 1:nDims
    dimName = dimensions(k);
    name = dash.string.indexedDimension(dimName);
    dash.assert.uniqueSet(indices{k}, name, header);
end

% Update each variable
method = 'design';
inputs = {indices, types, header};
obj = obj.editVariables(v, d, method, inputs, method);
obj = obj.updateLengths(v);

% Check each set of coupled variables for user-specified variables
[sets, nSets] = obj.coupledIndices;
for s = 1:nSets
    vCoupled = sets{s};
    isUserVar = ismember(vCoupled, v);

    % If there are user variables, check for secondary coupled variables
    if any(isUserVar) && ~all(isUserVar)
        vSecondary = vCoupled(~isUserVar);
        vTemplate = vCoupled(find(isUserVar,1));

        % Update secondary variables, informative error if failed
        [obj, failed, cause] = obj.coupleDimensions(vTemplate, vSecondary, header);
        if failed
            secondaryVariableError(obj, vTemplate, failed, cause, header);
        end
    end
end

end

function[] = secondaryVariableError(obj, vTemplate, vFailed, cause, header)

tName = obj.variables(vTemplate);
vName = obj.variables(vFailed);

vector = '';
if ~strcmp(obj.label, "")
    vector = sprintf('in %s ', obj.name);
end

id = sprintf('%s:couldNotUpdateCoupledVariable', header);
ME = MException(id, ['Cannot design the "%s" variable %sbecause the dimensions ',...
    'of coupled variable "%s" could not be updated to match "%s".'],...
    tName, vector, vName, tName);
ME = addCause(ME, cause);
throwAsCaller(ME);

end