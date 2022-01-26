function[grids, gridIndices, failed, cause] = parseGrids(grids, nVariables, header)

% Convert strings
if dash.is.strlist(grids)
    grids = string(grids);
end

% Require string or gridfile type
dash.assert.type(grids, ["string","gridfile"], 'grids', [], header);

% If scalar, use same grid for all variables. If vector, require one grid
% per variable
nGrids = numel(grids);
if nGrids == 1
    gridIndices = ones(nVariables, 1);
else
    gridIndices = 1:nVariables;
    dash.assert.vectorTypeN(grids, [], nVariables, 'grids', header);
end

% Preallocate
failed = 0;
cause = {};
if isstring(grids)
    gridObjects = cell(nGrids, 1);
end

% Cycle through grids and check for validity. Either build objects from
% file strings, or update objects
try
    for g = 1:nGrids
        if isstring(grids)
            gridObjects{g} = gridfile(grids(g));
        else
            grids(g).update;
        end
    end

    % Convert built objects to vector
    if isstring(grids)
        grids = [gridObjects{:}];
    end

% Catch failure causes
catch cause
    failed = g;
end

end