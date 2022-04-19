function[obj] = relocate(obj, variables, grids)
%% stateVector.relocate  Update paths to the .grid files associated with state vector variables
% ----------
%   obj = <strong>obj.relocate</strong>(-1, ...)
%   obj = <strong>obj.relocate</strong>(v, ...)
%   obj = <strong>obj.relocate</strong>(variableNames, ...)
%   Updates the .grid files associated with specified variables to a new
%   set of .grid files. If the first input is -1, updates all the variables
%   in the state vector.
%
%   obj = <strong>obj.relocate</strong>(variables, gridPaths)
%   obj = <strong>obj.relocate</strong>(variables, gridObjects)
%   Specify the new .grid files using either file paths or gridfile
%   objects.
% ----------
%   Inputs:
%       v (logical vector | linear indices [nVariables] | -1): The indices of variables in
%           the state vector whose .grid files should be updated. Either a
%           logical vector with one element per state vector variable, or a
%           vector of linear indices. If linear indices, may not contain
%           repeated values. If -1, selects all the variables in the state
%           vector.
%       variableNames (string vector [nVariables]): The names of variables in the state
%           vector whose .grid files should be updated. May not contain
%           repeat variable names.
%       gridPaths (string, scalar | vector [nVariables]): File paths to the new
%           .grid files. If scalar, uses the same .grid file path for all
%           input variables. If a vector, must have one element per listed
%           variable.
%       gridObjects (gridfile object, scalar | vector [nVariables]): Gridfile
%           objects for the new .grid files. If scalar, uses the same
%           gridfile object for all input variables. If a vector, must have
%           one element per listed variable.
%
%   Outputs:
%       obj (scalar stateVector object): The stateVector with updated .grid files
%
% <a href="matlab:dash.doc('stateVector.relocate')">Documentation Page</a>

% Setup
header = "DASH:stateVector:relocate";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Check variables, get indices
vars = obj.variableIndices(variables, false, header);
nVariables = numel(vars);

% Parse and build gridfiles
[grids, failed, cause] = obj.parseGrids(grids, nVariables, header);
if failed
    gridfileFailedError(obj, vars, failed, cause, header);
end

% Validate grids against values recorded in variables
[failed, cause] = obj.validateGrids(grids, vars, header);
if failed
    invalidReplacementError(obj, failed, grids, cause, header);
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
function[] = invalidReplacementError(obj, v, grids, cause, header)
var = obj.variables(v);

g = grids.whichGrid(v);
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