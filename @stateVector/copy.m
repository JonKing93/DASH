function[obj] = copy(obj, template, variables, methods)
%% stateVector.copy  Copy parameters from a template variable to other variables
% ----------
%   obj = obj.copy(template, variables)
%   Copies options from a template variable to other variables in the state
%   vector. Specifically, copies 1. Dimension types, 2. State indices, 3.
%   Reference indices, 4. Sequences, 5. Mean options, 6. Weighted Mean
%   options, 7. Ensemble metadata options, and 8. whether to allow overlap.
%
%   obj = obj.copy(template, variable, methods)
%   Explicitly indicate which parameters should be copied. The "methods"
%   input is a string vector that includes the names of methods whose
%   parameters should be copied from the template variable. If you provide
%   this input, then **ONLY** parameters from the listed methods will be
%   copied. Include the following strings to copy the associated parameters:
%
%   "design": Dimension types, state indices, and reference indices
%   "sequence": Sequence indices and sequence metadata
%   "mean": Dimensions with a mean, mean indices, and NaN options
%   "weightedMean": Dimensions with a weighted mean, weights
%   "metadata": Metadata options for ensemble dimensions
%   "overlap": Whether ensemble members should allow overlap
% ----------

% Setup
header = "DASH:stateVector:copy";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Error check the template
t = obj.variableIndices(template, true, header);
t = unique(t);
if numel(t)>1
    id = sprintf('%s:tooManyVariables', header);
    error(id, ['You can only specify a single template variable, but ',....
        'you have specified %.f template variables'], numel(t));
end

% Check variables, get indices
v = obj.variableIndices(variables, true, header);
v = unique(v);

% Default, error check methods
allowed = ["design";"sequence";"mean";"weightedMean";"metadata";"overlap"];
if ~exist('methods','var') || isempty(methods)
    methods = allowed;
end
methods = dash.assert.strlist(methods, 'methods', header);
dash.assert.strsInList(methods, allowed, 'method', 'supported method', header);

% Get settings for the template variable
template = obj.variables_(t).info;

% Copy design
if ismember("design", methods)
    obj = obj.design(v, template.dimensions, template.dimensionType, template.indices);
end

% Copy sequences
if ismember("sequence", methods)
    obj = obj.sequence(v, template.ensembleDimensions, template




