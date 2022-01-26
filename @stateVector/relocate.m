function[obj] = relocate(obj, variables, grids)

% Setup
header = "DASH:stateVector:relocate";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Check variables, get indices
vars = obj.variableIndices(variables, false, header);
nVariables = numel(vars);

% Parse and build gridfiles. 
[grids, gridIndices, failed, cause] = obj.parseGrids(grids, nVariables, header);
if failed
    gridfileFailedError(obj, vars, failed, cause);
end

% Cycle through variables.
for k = 1:nVariables
    v = vars(k);
    g = gridIndices(k);

    % Validate new grid
    [isvalid, cause] = obj.variables_(v).validateGrid(grids(g));
    if ~isvalid
        invalidReplacementError(obj, vars, g, grids, cause);
    end

    % Update file
    obj.gridfiles(v) = grids{g}.file;
end

end

% Errors
function[] = gridfileFailedError(obj, vars, g, cause)
v = vars(g);
var = obj.variables(v);
vector = '';
if ~strcmp(obj.label,"")
    vector = sprintf(' in %s', obj.name);
end
id = cause.identifier;
ME = MException(id, ['Could not relocate the "%s" variable%s because the ',...
    'new gridfile for the variable failed.'], var, vector);
ME = addCause(ME, cause);
throwAsCaller(ME);
end
function[] = invalidReplacementError(obj, vars, g, grids, cause)
if ~contains(cause.identifier, 'DASH')
    rethrow(cause);
end

v = vars(g);
var = obj.variables(v);
grid = grids(g);
vector = '';
if ~strcmp(obj.label,"")
    vector = sprintf(' in %s', obj.name);
end
badname = dash.string.elementName(g, 'New gridfile', numel(grids));

id = cause.identifier;
ME = MException(id, ['%s (%s) cannot be used for the "%s" variable%s.',...
    '\n\nNew gridfile: %s\nOld gridfile: %s'], badname, grid.name, ...
    var, vector, grid.file, obj.gridfiles(v));
ME = addCause(ME, cause);
throwAsCaller(ME);

end