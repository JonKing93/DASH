function[V, meta] = regrid(obj, X, varName)
%% Extracts a variable from a state vector ensemble and regrids it.

% Error check, variable index
dash.assertStrFlag(varName, 'varName');
v = dash.checkStrsInList(varName, obj.variableNames, 'varName', 'variable in the state vector');

% Check the array size matches the ensemble metadata
nState = obj.varLimit(end);
if size(X,1) ~= nState
    error('The number of rows of X (%.f) does not match the length of the state vector (%.f).', size(X,1), nState);
end

% Extract the variable and its metadata
V = X(obj.varLimit(v,1):obj.varLimit(v,2), :);
meta = obj.metadata.(varName).state;

% Get the gridded size.
siz = size(V);
gridSize = obj.stateSize{v};

% Remove singleton dimensions
single = gridSize==1;
gridSize(single) = [];
meta = rmfield(meta, obj.dims{v}(single));

% Get the new size and reshape
newSize = [gridSize, siz(2:end)];
V = reshape(V, newSize);

end

