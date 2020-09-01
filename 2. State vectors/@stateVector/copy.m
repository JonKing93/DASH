function[obj] = copy(obj, templateName, varNames, varargin)
%% Copies design options from a template variable to other variables in a
% state vector.
%
% obj = obj.copy( templateName, varNames )
% Copies all options from a template variable to other variables. This
% includes dimension types, state indices, reference indices, sequences,
% mean options, and weights for weighted means.
%
% obj = obj.copy( ..., 'sequence', copySequences )
% Specify whether to copy sequence options.
%
% obj = obj.copy( ...,  'weightedMean', copyWeights )
% Specify whether to copy weights for weighted means.
%
% obj = obj.copy( ..., 'mean', copyMeans )
% Specify whether to copy mean options. Note that this does not include
% weights for a weighted mean. Only whether a mean is being taken over a
% dimension, mean indices, and NaN options.
%
% obj = obj.copy( ..., 'design', copyDesigns )
% Specify whether to copy dimension types, state indices, and reference
% indices.
%
% ----- Inputs -----
%
% templateName: The name of a template variable. A string scalar or
%    character row vector.
%
% varNames: The name of the variable to which options are being copied. A
%    string vector or cellstring vector.
%
% copySequences: Scalar logical. If true (default), copies sequence options.
%    If false, does not.
%
% copyMeans: Scalar logical. If true (default), copies mean options. If
%    false, does not.
%
% copyWeights: Scalar logical. If true (default), copies weights for 
%    weighted means. If false, does not.
%
% copyDesigns: Scalar logical. If true (default), copies dimension types,
%    state indices, and reference indices. If false, does not.
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Error check names and get dimension indices
t = obj.checkVariables(templateName);
v = obj.checkVariables(varNames);

% Parse optional inputs
[copySequences, copyMeans, copyWeights, copyDesigns] = parseInputs( varargin, ...
    ["sequence","mean","weightedMean","design"], {true, true, true, true}, 2 );

% Error check
dash.assertScalarLogical(copySequences, 'copySequences');
dash.assertScalarLogical(copyMeans, 'copyMeans');
dash.assertScalarLogical(copyWeights, 'copyWeights');
dash.assertScalarLogical(copyDesigns, 'copyDesigns');

% Get the template variable
var = obj.variables(t);

% Designs
if copyDesigns
    obj = obj.design(varNames, var.dims, var.isState, var.indices);
end

% Sequences
if copySequences
    ens = ~var.isState;
    obj = obj.sequence(varNames, var.dims(ens), var.seqIndices(ens), var.seqMetadata(ens));
end

% Means
if copyMeans
    m = var.takeMean;
    obj = obj.mean(varNames, var.dims(m), var.mean_Indices(m), var.omitnan(m));
end

% Weighted means
if copyWeights
    w = bar.hasWeights;
    obj = obj.weightedMean(varNames, var.dims(w), var.weightCell(w));
end

end