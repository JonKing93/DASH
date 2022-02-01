function[obj] = relocate(obj, variables, grids)

% Setup
header = "DASH:stateVector:relocate";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Check variables, get indices
vars = obj.variableIndices(variables, false, header);
nVariables = numel(vars);

% Parse and build gridfiles
[grids, failed, cause] = obj.parseGrids(grids, nVariables, header);
if failed
    gridfileFailedError(obj, vars, g, cause, header);
end

% Validate grids against values recorded in variables
[failed, cause] = obj.validateGrids(grids, vars, header);
if failed
    invalidReplacementError(failed, grids, g, cause, header);
end

% Update file paths
files = [grids.gridfiles.file];
obj.gridfiles(vars) = files(grids.whichGrid);

end

% Errors
function[] = gridfileFailedError(obj, vars, g, cause, header)
v = vars(g);
var = obj.variables(v);
vector = '';
if ~strcmp(obj.label,"")
    vector = sprintf(' in %s', obj.name);
end
id = sprintf('%s:gridfileFailed', header);
ME = MException(id, ['Could not relocate the "%s" variable%s because the ',...
    'new gridfile for the variable failed.'], var, vector);
ME = addCause(ME, cause);
throwAsCaller(ME);
end
function[] = invalidReplacementError(obj, v, grids, g, cause, header)
var = obj.variables(v);
grid = grids.gridfiles(g);
vector = '';
if ~strcmp(obj.label,"")
    vector = sprintf(' in %s', obj.name);
end
badname = dash.string.elementName(g, 'New gridfile', numel(grids));

id = sprintf('%s:invalidReplacement', header);
ME = MException(id, ['%s (%s) cannot be used for the "%s" variable%s.',...
    '\n\nNew gridfile: %s\nOld gridfile: %s'], badname, grid.name, ...
    var, vector, grid.file, obj.gridfiles(v));
ME = addCause(ME, cause);
throwAsCaller(ME);

end