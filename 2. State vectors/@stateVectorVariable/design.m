function[obj] = design(obj, dim, type, indices)
%% Designs a dimension of a stateVectorVariable
%
% obj = obj.design(dim, type)
%
% obj = obj.design(dim, 'state', stateIndices)
%
% obj = obj.design(dim, 'ens', ensIndices)
% obj = obj.design(dim, 'ensemble', ensIndices)
%
% ----- Inputs -----
%
% dim: The name of one of the variable's dimensions. A string.
%
% type: A string indicating the type of the dimension.
%    'state' or 's': A state dimension
%    'ensemble' or 'ens' or 'e': An ensemble dimension
%
% stateIndices: The indices of required data along the dimension in the
%    variable's .grid file. Either a vector of linear indices or a logical
%    vector the length of the dimension.

% Error check. Get the dimension index
dash.assertStrFlag(dim, 'dim');
dash.assertStrFlag(type, 'type');
d = obj.checkDimensions(dim, false);

% Check that type is recognized and get the name of the indices
t = dash.checkStrsInList(type, ["state","s","ensemble","ens","e"], 'type', 'recognized flag');

% Toggles and names for state vs ens
if t<3
    isState = true;
    name = 'stateIndices';
else
    isState = false;
    name = 'ensIndices';
end

% Default for indices and error check
if ~exist('indices','var') || isempty(indices)
    indices = (1:obj.gridSize(d))';
end
indices = dash.checkIndices(indices, name, obj.gridSize(d), obj.dims(d));

% State dimension
if isState
    obj.size(d) = numel(indices);
    obj.isState(d) = true;
    obj.stateIndices{d} = indices;
    
    % Reset ensemble properties
    obj.ensIndices{d} = [];
    obj.seqIndices{d} = [];
    obj.seqMetadata{d} = [];
    
% Ensemble dimension
else
    obj.isState(d) = false;
    obj.ensIndices{d} = indices;
    obj.size(d) = 1;
    
    % Initialize ensemble properties
    obj.seqIndices{d} = 0;
    obj.seqMetadata{d} = NaN;
    
    % Reset state properties
    obj.stateIndices{d} = [];
end

% Check the new size of the dimension matches the number of mean weights
if obj.takeMean(d) && ~isnan(obj.nWeights(d)) && obj.size(d)~=obj.nWeights(d)
    error(['The %s dimension of variable "%s" was previously added to a weighted mean, and the new size of %s in the state vector (%.f) ',...
        'no longer matches the number of weights (%.f). You may want to reset the weighted mean using: \n>> obj.mean("%s").'], dim, obj.name, dim, obj.size(d), obj.nWeights(d), obj.name);
end

end