function[obj] = design(obj, variables, dimensions, type, indices)
%% stateVector.design  Design the dimensions of variables in a state vector
% ----------

% Setup
header = "DASH:stateVector:design";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Error check variables and get indices. Also check dimensions
vars = obj.variableIndices(variables, false, header);
dimensions = dash.assert.strlist(dimensions);

% Error check the dimensions
dimensionErrorCheck;

% Parse dimension types
nDims = numel(dimensions);
isState = dash.assert.switches(dimensions, ["s","state"], ["e","ens","ensemble"], numel(v));

% Parse indices
if ~exist('indices','var')
    indices = cell(1, nDims);
else
    dash.assert.indexCollection(indices, nDims, [], dimNames, header);
end

% Update each variable
for k = 1:numel(vars)
    v = vars(k);
    try
        obj.variables_(v) = obj.variables_(v).design(dimensions, isState, indices);

    % Provide informative error message if failed
    catch ME
        designError(obj, v, ME);
    end
end

end

% Error messages
function[] = designError(obj, v, cause)

% If not a DASH error, just rethrow
if ~contains(ME.identifier, "DASH")
    rethrow(ME);
end

% Check if the state vector has a label and if the error has an associated dimension
haslabel = ~strcmp(obj.label, "");
hasDimension = ~isempty(cause.cause);

% Build the header
dim = '';
if hasDimension
    dim = sprintf('the "%s" dimension of ', cause.cause);
end

vector = '';
if haslabel
    vector = sprintf(' in %s', obj.name);
end

header = sprintf('Cannot design %sthe "%s" variable%s. Cause of error:', ...
    dim, obj.variableNames(v), vector);

% Build the tail
dim = '';
if hasDimension
    dim = sprintf('Dimension: %s\n', cause.cause);
end

vector = '';
if haslabel
    vector = sprintf('\nState vector: %s', obj.label);
end

tail = sprintf('%sVariable: %s%s', dim, obj.variableNames(v), vector);

% Build the full error
id = cause.identifier;
error(id, '%s\n\n%s\n\n%s', header, cause.message, tail);

end