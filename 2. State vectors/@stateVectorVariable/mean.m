function[obj] = mean(obj, dims, weights, omitnan)
%% Specify to take a mean over dimensions of a stateVectorVariable
%
% obj = obj.mean(dims)
% Takes the mean over the specified dimensions.
%
% obj = obj.mean(dims, weightCell)
% obj = obj.mean(dims, weightMatrix)
% Uses a weighted mean.
%
% obj = obj.mean(dims, weights, nanflag)
% obj = obj.mean(dims, weights, omitnan)
% Specify how to treat NaN values along each dimension. By default, NaN
% values are included in means.
%
% obj.mean
% Resets the mean.
%
% ***Note: Each call to obj.mean(...) resets the settings for any means. So
% any previous settings will be deleted.
%
% ----- Inputs -----
%
% varName: The name of a variable in the state vector.
%
% dims: The names of dimensions over which to take a mean. A string vector 
%    or cellstring vector. Dimensions may be in any order and may not
%    contain duplicate names.
%
% weightCell: A cell vector. Each element contains the weights for one
%    dimension; must follow the same order of dimensions as dims. The
%    weights for each dimension may either be an empty array or a numeric
%    vector the length of the dimension in the state vector. If empty,
%    takes an unweighted mean over the dimension. If a vector, may not
%    contain NaN or Inf elements.
%
% weightArray: An N-dimensional numeric array containing weights for 
%    taking a mean across specified dimensions. Must have a dimension for 
%    each dimension listed in dims. The dimensions of weightArray must
%    follow the same order as dims and be the length of the dimension in
%    the stateVector. May not contain NaN or Inf.
%
% nanflag: A string or cellstring. If a scalar, specifies how to treat NaN
%    values for all dimensions when taking a mean. Use "includenan"
%    (the default), to include NaN values in means; use "omitnan" to
%    exclude NaN values. If a vector, elements may be "includenan" or 
%    "omitnan" and indicate how to treat NaNs along a particular dimension.
%    Must have one element per dimension listed in dims and be in the same
%    dimension order as dims.
%
% omitnan: A logical. If a scalar, specifies whether to include NaN values
%    (false -- the default), or exclude NaN values (true) from all
%    dimensions when taking a mean. If a vector, each element indicates how
%    to treat NaNs along a particular dimension. Must have one element per
%    dimension listed in dims and be in the same dimension order as dims.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% Defaults, dimension indices
d = [];
if exist('dims','var') && ~isempty(dims)
    d = obj.checkDimensions(dims, true);
end
nDims = numel(d);
if ~exist('weights','var') || isempty(weights)
    weights = cell(1, numel(d));
end
if ~exist('omitnan','var') || isempty(omitnan)
    omitnan = false;
end

% Parse nanflag
if islogical(omitnan) 
    if ~isscalar(omitnan)
        dash.assertVectorTypeN(omitnan, [], nDims, 'omitnan is not a scalar, so it');
    end
elseif ischar(omitnan) || isstring(omitnan) || iscellstr(omitnan)
    dash.checkStrsInList(input, ["includenan","omitnan"], 'nanflag', 'recognized flag');
    if ~ismember(numel(string(omitnan)), [1 nDims])
        error('nanflag may have either 1 or %.f elements, but it has %.f instead.', nDims, numel(omitnan));
    end
    omitnan = strcmp(omitnan, "omitnan");
else
    error('NaN options must either be a logical (omitnan) or string (nanflag)');
end

% Reset mean specifications. Save new dimensions and nan options
obj = obj.resetMean;
obj.takeMean(d) = true;
obj.omitnan(d) = omitnan;

% Error check the overall cell of weights
if iscell(weights)
    dash.assertVectorTypeN(weights, [], nDims, 'weightCell');
    
    % Error check the weights for each dimension
    for k = 1:nDims
        if ~isempty(weights{k})         
            name = sprintf('The weights for dimension "%s" (element %.f of weightCell)', obj.dims(d(k)), k);
            dash.assertVectorTypeN(weights{k}, 'numeric', obj.size(d(k)), name);
            if any(isnan(weights{k})) || any(isinf(weights{k}))
                error('%s may not contain NaN or Inf.', name);
            end
            
            % Record the number of weights along the dimension
            obj.nWeights(d(k)) = numel(weights{k});
        end        
    end
    
    % Save
    obj.weightCell(d) = weights;
    
% Error check matrix weights
elseif isnumeric(weights)
    dash.assertRealDefined(weights, 'weightArray');
    
    % Check there are no more than nDims non-singleton dimensions
    siz = size(weights);
    last = max([1, find(siz~=1, 1, 'last')]);
    if last > nDims
        error('weightArray should have %.f dimensions, but it has %.f instead.', nDims, last);
    end
    
    % Get the size in all specified dims. Check they match dimension sizes
    siz(last+1:end) = [];
    siz(last+1:nDims) = 1;
    if ~isequal(siz, obj.size(d))
        bad = find(siz~=obj.size(d), 1);
        error('Dimension %.f of weightArray (%s) must have %.f elements, but it has %.f elements instead.', bad, obj.dims(d(bad)), obj.size(d(bad)), siz(bad));
    end
    
    % Save
    obj.nWeights(d) = siz;
    obj.weightArray = weights;
    
% Anything else
else
    error('weights must either be a cell vector or numeric matrix.');
end

end