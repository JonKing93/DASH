function[obj] = weightedMean(obj, dims, weights)
%% Specify options for taking a weighted mean over dimensions.
%
% obj = obj.weightedMean(dim, weights)
% Takes a weighted mean over a dimension.
%
% obj = obj.weightedMean(dims, weightCell)
% obj = obj.weightedMean(dims, weightArray)
% Takes a weighted mean over multiple dimensions.
%
% ----- Inputs -----
%
% dim: The name of a dimension over which to take a weighted mean. A string
%
% weights: A numeric vector containing the mean weights. If dim is a state
%    dimension, must have a length equal to the number of state indices.
%    If dim is an ensemble dimension, the length must be equal to the
%    number of mean indices. (See stateVector.info to summarize dimension
%    properties). May not contain NaN, Inf, or complex numbers.
%
% weightCell: A cell vector. Each element contains mean weights for one
%    dimension listed in dims. Must be in the same order as dims.
%
% weightArray: An N-dimensional numeric array containing weights for taking
%    a mean across specified dimensions. Must have a dimension for each
%    dimension listed in dims and must have the same dimension order as
%    dims. The length of each dimension of weightArray must be equal to
%    either the number of state indices or mean indices, as appropriate.
%    (See the "weights" input for details). May not contain NaN, Inf, or
%    complex numbers. If an element of weightCell is an empty array, uses
%    equal weights for elements along the associated dimension.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% Error check, dimension index
[d, dims] = obj.checkDimensions(dims);
nDims = numel(d);

% Add any new dimensions to mean. Note that weights exist
obj = obj.mean( dims(~obj.takeMean(d)) );
obj.hasWeights(d) = true;

% Error check weightArray
if nDims>1 && isnumeric(weights)
    dash.assertRealDefined(weights, 'weightArray');
    
    % Check there are no more than nDims non-singleton dimensions
    siz = size(weights);
    last = max([1, find(siz~=1, 1, 'last')]);
    if last > nDims
        tooManyDimsError(obj, last, nDims);
    end
    
    % Get the size in all specified dims. Check they match dimension sizes
    siz(last+1:end) = [];
    siz(last+1:nDims) = 1;
    if ~isequal(siz, obj.meanSize(d))
        bad = find(siz~=obj.meanSize(d),1);
        incorrectLengthError(obj, obj.dims(d(bad)), bad, siz(bad), obj.meanSize(d(bad)));
    end
    
    % Permute to match internal order. Break into weightCell. Save
    weights = dash.permuteDimensions(weights, d, false, numel(obj.dims));
    for k = 1:nDims
        weightVector = sum(weights, d([1:k-1,k+1:end]));
        obj.weightCell{d(k)} = weightVector(:);
    end
    
% Parse and error check weightCell
else
    [weights, wasCell] = dash.parseInputCell(weights, nDims, 'weightCell');
    name = 'weights';

    % If weights is empty, this is an unweighted mean
    for k = 1:nDims
        if isempty(obj.weightCell{d(k)})
            obj.hasWeights(d(k)) = false;
            
        % Otherwise, error check weights and update
        else
            if wasCell
                name = sprintf('Element %.f of weightCell', k);
            end
            dash.assertVectorTypeN(weights{k}, 'numeric', obj.meanSize(d(k)), name);
            dash.assertRealDefined(weights{k}, name);
            obj.weightCell{d(k)} = weights{k}(:);
        end
    end
end

end

% Long error messages
function[] = tooManyDimsError(obj, last, nDims)
error(['weightArray for variable "%s" should have %.f dimensions, but it ', ...
    'has %.f instead.'], obj.name, nDims, last);
end
function[] = incorrectLengthError(obj, dim, bad, newSize, oldSize)
error(['Dimension %.f of weightArray (%s) for variable "%s" must have ',...
    '%.f elements, but it has %.f elements instead.'], bad, dim, ...
    obj.name, oldSize, newSize);
end