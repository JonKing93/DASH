function[grids] = buildGrids(obj)

% Get the unique set of gridfiles. Note which grid is used by each variable
[grids, ~, whichGrid] = unique(obj.gridfiles);

% Build each gridfile, informative error if failed
[grids, failed, cause] = obj.buildGrids(grids);
if failed
    couldNotBuildGridfileError(obj, grids, whichGrid, failed, cause)
end

% Validate the grids against each variable
for v = 1:obj.nVariables
    grid = grids( whichGrid(v) );
    [isvalid, cause] = obj.variables_(v).validateGrid(grid);
    if ~isvalid
        invalidGridfileError(obj, v, grid, cause);
    end
end

% Organize structure array
grids = struct('whichGrid', whichGrid, 'gridfiles', grids);

end