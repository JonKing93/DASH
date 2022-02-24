function[obj] = design(obj, variables, dimensions, types, indices)
%% stateVector.design  Design the dimensions of variables in a state vector
% ----------
%   obj = obj.design(v, dimensions, "s" | "state" | true)
%   obj = obj.design(variableNames, dimensions, "s" | "state" | true)
%   Sets the indicated dimensions as state dimensions for the specified
%   variables.
%
%   obj = obj.design(v, dimensions, "e" | "ens" | "ensemble" | false)
%   obj = obj.design(variableNames, dimensions, "e" | "ens" | "ensemble" | false)
%   Sets the indicated dimensions as ensemble dimensions for the specified
%   variables.
%
%   obj = obj.design(v, dimensions, types)
%   obj = obj.design(variableNames, dimensions, types)
%   Specify the type of each indicated dimension. Allows dimensions to be a
%   mix of state and ensemble dimensions.
%
%   obj = obj.design(..., indices)
%   Also specifies state and/or reference indices for the indicated
%   dimensions.
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
%       types (vector [1 | nDimensions], string | logical): Whether each
%           named dimension is a state or an ensemble dimension. If a
%           scalar, applies the same setting to all named dimensions. If a
%           vector, must have one element per named dimension.
%
%           If types is logical, use true to indicate a state dimension and
%           false to indicate an ensemble dimension. If a string vector,
%           use "s" or "state" to indicate state dimensions and "e", "ens",
%           or "ensemble" to indicate ensemble dimensions.
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
options = {["e","ens","ensemble"], ["s","state"]};
isstate = dash.parse.switches(types, options, nDims, ...
                    'Dimension type', 'recognized dimension type', header);

% Parse indices
if ~exist('indices','var')
    indices = cell(1, nDims);
else
    dash.assert.indexCollection(indices, nDims, [], dimensions, header);
end

% Require unique state/reference indices
for k = 1:nDims
    dimName = dimensions(k);
    name = dash.string.indexedDimension(dimName);
    dash.assert.uniqueSet(indices{k}, name, header);
end

% Update each variable
method = 'design';
inputs = {isstate, indices, header};
obj = obj.editVariables(v, d, method, inputs, method);

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