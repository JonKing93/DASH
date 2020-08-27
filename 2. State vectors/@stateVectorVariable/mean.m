function[obj] = mean(obj, dim, indices, omitnan)
%% Specifies to take a mean over a dimension.
%
% obj = obj.mean(stateDim)
% obj = obj.mean(stateDim, []);
% Take a mean over a state dimension.
%
% obj = obj.mean(ensDim, indices);
% Specify how to take a mean over an ensemble dimension.
%
% obj = obj.mean(..., nanflag)
% obj = obj.mean(..., omitnan)
% Specify how to treat NaN values when taking a mean
%
% ----- Inputs -----
%
% stateDim: The name of a state dimension for the variable. A string.
%
% ensDim: The name of an ensemble dimension for the variable. A string.
%
% indices: Mean indices for an ensemble dimension. A vector of integers
%    that indicates the position of mean data-elements relative to the
%    sequence data-elements. 0 indicates a sequence data-element. 1 is the
%    data-element following a sequence data-element. -1 is the data-element
%    before a sequence data-element, etc. Mean indices may be in any order 
%    and cannot have a magnitude larger than the length of the dimension in
%    the .grid file. 
%
% nanflag: A string that indicates how to treat NaN values along the
%    dimension. Use "includenan" to use NaN values (default). Use "omitnan"
%    to remove NaN values from the mean.
%
% omitnan: A scalar logical that indicates whether to include NaN values in
%    the mean (false -- default), or whether to remove them (true).
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object.

% Error check, dimension index. Parse indices.
d = obj.checkDimensions(dim, false);
hasIndices = exist('indices','var') && ~isempty(indices);

% Default, parse, error check omitnan
if ~exist('omitnan','var') || isempty(omitnan)
    omitnan = false;
elseif islogical(omitnan)
    dash.assertScalarLogical(omitnan, 'omitnan');
elseif isstrflag(omitnan)
    dash.checkStrsInList(omitnan, ["includenan","omitnan"], 'nanflag', 'recognized flags');
    omitnan = strcmpi(omitnan, "omitnan");
else
    error('NaN options must either be a scalar logical or string scalar.');
end

% State dimensions. Indices not allowed. Get mean size
if obj.isState(d)
    if hasIndices
        error('Only ensemble dimensions can have mean indices, but "%s" is a state dimension in variable %s. To make %s an ensemble dimension, see "stateVector.design".', dim, obj.name, dim);
    end
    meanSize = obj.size(d);
    
% Ensemble dimensions. Require, error check, and save indices
else
    if ~hasIndices
        error('"%s" is an ensemble dimension in variable %s, so you must specify mean indices in order to take a mean.', dim, obj.name);
    end
    obj.checkEnsembleIndices(indices, d);
    obj.mean_Indices{d} = indices;
    
    % Check that the mean indices do not disrupt a weighted mean
    meanSize = numel(indices);
    if obj.hasWeights(d) && meanSize~=obj.meanSize(d)
        error('The "%s" dimension of variable "%s" is being used in a weighted mean, but the number of mean indices (%.f) does not match the number of weights (%.f). Either specify %.f mean indices or reset the mean options using "stateVector.resetMeans".', dim, obj.name, meanSize, obj.meanSize(d), obj.meanSize(d));
    end
end

% Update
obj.takeMean(d) = true;
obj.meanSize(d) = meanSize;
obj.omitnan(d) = omitnan;

end
