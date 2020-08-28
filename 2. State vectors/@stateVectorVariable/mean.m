function[obj] = mean(obj, dims, indices, omitnan)
%% Specifies options for taking a mean over dimensions.
%
% obj = obj.mean(stateDim)
% obj = obj.mean(stateDim, []);
% Take a mean over a state dimension.
%
% obj = obj.mean(ensDim, indices);
% Specify how to take a mean over an ensemble dimension.
%
% obj = obj.mean(dims, indexCell)
% Specify how to take a mean over multiple dimensions.
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
% dims: The names of multiple dimensions. A string vector or cellstring
%    vector. May not repeat dimension names.
%
% indices: Mean indices for an ensemble dimension. A vector of integers
%    that indicates the position of mean data-elements relative to the
%    sequence data-elements. 0 indicates a sequence data-element. 1 is the
%    data-element following a sequence data-element. -1 is the data-element
%    before a sequence data-element, etc. Mean indices may be in any order 
%    and cannot have a magnitude larger than the length of the dimension in
%    the .grid file.
%
% indexCell: A cell vector. Each element contains mean indices for one
%    dimension listed in dims. Must be in the same order as dims. Use an
%    empty array for elements corresponding to state dimensions.
%
% nanflag: Options are "includenan" to use NaN values (default) and
%    "omitnan" to remove NaN values. Use a string scalar to specify an
%    option for all dimensions listed in dims. Use a string vector to
%    specify different options for the different dimensions listed in dims.
%
% omitnan: If false (default) includes NaN values in a mean. If true,
%    removes NaN values. Use a scalar logical to use the same option for
%    all dimensions listed in dims. Use a logical vector to specify
%    different options for the different dimensions listed in dims.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object.

% Error check, dimension index.
d = [];
if ~isempty(dims)
    d = obj.checkDimensions(dims);
end
nDims = numel(d);

% Defaults, error check, parse indices
if ~exist('indices','var') || isempty(indices)
    indices = cell(1, nDims);
end
[indices, wasCell] = obj.parseInputCell(indices, nDims, 'indexCell');

% Default, parse, error check omitnan
if ~exist('omitnan','var') || isempty(omitnan)
    omitnan = false;
end
omitnan = obj.parseLogicalString(omitnan, nDims, 'omitnan', 'nanflag', ["omitnan","includenan"], 1, 'NaN options');

% Ensemble dimensions. Require indices
name = 'indices';
for k = 1:nDims
    if ~obj.isState(d(k))
        if isempty(indices{k})
            ensMissingIndicesError(obj, dims(k));
        end
        
        % Error check indices. Save
        if wasCell
            name = sprintf('Element %.f of indexCell', k);
        end
        obj.assertEnsembleIndices(indices{k}, d(k), name);
        obj.mean_Indices{d(k)} = indices{k}(:);
    
        % Check that the mean indices do not disrupt a weighted mean
        meanSize = numel(indices{k});
        if obj.hasWeights(d(k)) && meanSize~=obj.meanSize(d(k))
            weightsNumberError(obj, dims(k), meanSize, obj.meanSize(d(k)));
        end
    
    % State dimensions. Indices not allowed. Get mean size
    else 
        if ~isempty(indices{k})
            stateHasIndicesError(obj, dims(k));
        end
        meanSize = obj.size(d(k));        
    end

    % Update mean Size
    obj.meanSize(d(k)) = meanSize;
end

% Update general mean properties
obj.takeMean(d) = true;
obj.omitnan(d) = omitnan;

end

% Long error messages
function[] = stateHasIndicesError(obj, dim)
error(['Only ensemble dimensions can have mean indices, but "%s" is a ',...
    'state dimension in variable %s. To make %s an ensemble dimension, ',...
    'see "stateVector.design".'], dim, obj.name, dim);
end
function[] = ensMissingIndicesError(obj, dim)
error(['"%s" is an ensemble dimension in variable %s, so you must specify ',...
    'mean indices in order to take a mean.'], dim, obj.name);
end
function[] = weightsNumberError(obj, dim, newSize, oldSize)
error(['The "%s" dimension of variable "%s" is being used in a weighted ',...
    'mean, but the number of mean indices (%.f) does not match the number ',...
    'of weights (%.f). Either specify %.f mean indices or reset the mean ',...
    'options using "stateVector.resetMeans".'], dim, obj.name, newSize, ...
    oldSize, oldSize);
end