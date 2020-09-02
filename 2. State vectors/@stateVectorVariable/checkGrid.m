function[] = checkGrid(obj, grid)
%% Checks that a gridfile object matches the dimensions and size of the
% original grid associated with a stateVectorVariable
%
% obj.checkGrid(grid)
%
% ----- Inputs -----
%
% grid: A gridfile object for the variable

if ~isequal(obj.dims, grid.dims)
    gridChangedError(obj, true);
elseif ~isequal(obj.gridSize, grid.size)
    gridChangedError(obj, false);
end

end

% Long error message
function[] = gridChangedError(var, isDims)
tail = sprintf(['changed since variable "%s" was added to the state vector. ', ...
    'You may want to remove "%s" from the state vector and rebuild it.'], ...
    var.name, var.name);
if isDims
    error('The dimensions in .grid file "%s" have %s', var.file, tail);
else
    error('The size of .grid file "%s" has %s', var.file, tail);
end
end