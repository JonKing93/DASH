function[obj] = meanIndices(obj, dim, indices)
%% Specifies how to take a mean for an ensemble dimension.
%
% obj = obj.sequence(dim, indices);
%
% ----- Inputs -----
%
% dim: The name of an ensemble dimension in the .grid file for the 
%    variable. A string.
%
% indices: The mean indices. A vector of integers that indicates the
%    position of mean data-elements relative to the sequence data-elements.
%    0 indicates a sequence data-element. 1 is the data-element following a
%    sequence data-element. -1 is the data-element before a sequence
%    data-element, etc. Mean indices may be in any order and cannot have a
%    magnitude larger than the length of the dimension in the .grid file.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object.

% Require ensemble dimenison. Error check indices
d = obj.checkEnsembleIndices(dim, indices);

% Check that the mean indices do not disrupt any previous weighted means
nIndex = numel(indices);
if obj.hasWeights(d) && nIndex~=obj.nWeights(d)
    error('The "%s" dimension of variable "%s" is being used in a weighted mean, but the number of mean indices (%.f) does not match the number of weights (%.f). Either specify %.f mean indices or reset the weighted mean using:\n>> obj.resetMean("%s")', dim, obj.name, nIndex, obj.nWeights(d), obj.nWeights(d), obj.name);
end

% Update
obj.mean_Indices{d} = indices;
obj.takeMean(d) = true;
obj.meanSize(d) = nIndex;

end
