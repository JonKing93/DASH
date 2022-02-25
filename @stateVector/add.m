function[obj] = add(obj, variableNames, grids, autocouple)
%% stateVector.add  Adds variables to a stateVector
% ----------
%   obj = obj.add(variableNames, grid)
%   Adds variables to a state vector and specifies a single .grid file that
%   contains the data for all the different variables.
%
%   obj = obj.add(variableNames, grids)
%   Specify different .grid files for the variables being added to the
%   state vector. Each .grid file should contain the data for the
%   corresponding new variable. You may repeat .grid files when several
%   state vector variables are derived from the same .grid file.
%
%   obj = obj.add(..., autocouple)
%   Specify auto-coupling settings for the new variables. Use true, "a",
%   "auto", or "automatic" to automatically couple the new variables to
%   existing variables in the state vector (default); note that the new
%   variables will not be coupled to existing variables that have
%   autocoupling disabled. Use false, "m", "man", or "manual" to disable
%   autocoupling.
%
%   If autocouple has a single element, applies the same setting to all of
%   the new variables. Otherwise, autocouple should have one element per
%   new variable. Each element indicates the desired setting for the
%   correpsonding variable. This vector syntax allows you to use different
%   settings for different variables.
% ----------
%   Inputs:
%       variableNames (string vector [nVariables]): The names of the new
%           variables being added to the state vector. Variable names
%           **DO NOT** need to match the names of variables in data source
%           files. Use any name you find meaningful. Names cannot duplicate
%           the names of variables already in the state vector.
%
%           Variable names must be valid MATLAB variable names. They must
%           1. start with a letter, 2. only contain numbers, letters,
%           and underscores, and 3. cannot match a MATLAB keyword.
%       grid (string scalar | scalar gridfile object): A .grid file that
%           contains the data for all the newly added variables. Either a
%           gridfile object, or the filepath to a .grid file. The .grid file
%           must have at least one dimension.
%       grids (vector [nVariables], string | gridfile):
%           The collection of .grid files that contain the data for the new variables.
%           Must have one element per new variable. May either be a vector
%           of gridfile objects, or .grid filepaths.
%       autocouple (vector [nVariables], logical | string): Indicates the
%           autocoupling setting to use for each new variable. If
%           autocouple has a single element, applies the same setting to
%           all the new variables.
%           [true|"a"|"auto"|"automatic" (Default)]: Automatically couple new variable
%               to existing, auto-couple enabled variables.
%           [false|"m"|"man"|"manual"]: Disable autocoupling for the new variable
%
%   Outputs:
%       obj (scalar stateVector object): The stateVector object updated to
%           include the new variables.
%
% <a href="matlab:dash.doc('stateVector.add')">Documentation Page</a>

% Setup
header = "DASH:stateVector:add";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Error check the names of the new variables
varNames = dash.assert.strlist(variableNames, 'variableNames', header);
varNames = varNames(:);
obj.assertValidNames(varNames, header);
nVariables = numel(varNames);

% Default, error check autocoupling options
if ~exist('autocouple','var') || isempty(autocouple)
    autocouple = true;
end
offOn = {["m","man","manual"], ["a","auto","autocouple"]};
autocouple = dash.parse.switches(autocouple, offOn, nVariables, ...
    'autocouple', 'recognized auto-coupling option', header);

% Parse and build gridfiles. Informative error if failed
[grids, failed, cause] = obj.parseGrids(grids, nVariables, header);
if failed
    gridfileFailedError(obj, varNames, failed, cause, header);
end

% Require each gridfile to have dimensions
for g = 1:numel(grids.gridfiles)
    grid = grids.gridfiles(g);
    if isempty(grid.dimensions)
        noDimensionsError(obj, varNames, grids, g, header);
    end
end

% Build each new state vector variable
for v = 1:nVariables
    g = grids.whichGrid(v);
    grid = grids.gridfiles(g);
    newVariable = dash.stateVectorVariable(grid);

    % Add to the state vector
    obj.variables_ = [obj.variables_; newVariable];
    obj.gridfiles = [obj.gridfiles; grid.file];
end

% Update variable properties
v = obj.nVariables + (1:nVariables);
obj.variableNames(v) = varNames;
obj.allowOverlap(v) = false;
obj.nVariables = v(end);

% Initialize coupling
obj.coupled(v,:) = false;
obj.coupled(:,v) = false;
obj.coupled(1:obj.nVariables+1:end) = true;

% Autocouple to existing variables (no need to couple to each other,
% because new variables only have state dimensions)
if any(autocouple) && any(obj.autocouple_)
    vTemplate = find(obj.autocouple_, 1);
    vUpdate = v(autocouple);
    [obj, failed, cause] = obj.coupleDimensions(vTemplate, vUpdate, header);
    if failed
        couldNotAutocoupleError(obj, vTemplate, failed, cause, header);
    end
end

% Update autocouple and coupling status of autocoupled variables
obj.autocouple_(v) = autocouple;
if any(autocouple)
    vCouple = find(obj.autocouple_);
    obj.coupled(vCouple, vCouple) = true;
end

% Update variable lengths
obj.lengths(v) = NaN;
obj = obj.updateLengths(v);

end

% Errors
function[] = noDimensionsError(obj, varNames, grids, g, header)
v = find(grids.whichGrid==g,1);
var = varNames(v);
grid = grids.gridfiles(g);
id = sprintf('%s:noDimensionsInGridfile', header);
ME = MException(id, ['Could not add variable "%s" to %s because the gridfile ',...
    'for the variable (%s) has no dimensions.\n\ngridfile: %s'], ...
    var, obj.name, grid.name, grid.file);
throwAsCaller(ME);
end
function[] = gridfileFailedError(obj, vars, g, cause, header)

% Supplement failed build
var = vars(g);
id = sprintf('%s:gridfileFailed', header);
ME = MException(id, ['Could not add variable "%s" to %s because the gridfile ',...
    'for the variable failed.'], ...
    var, obj.name);
ME = addCause(ME, cause);
throwAsCaller(ME);

end
function[] = couldNotAutocoupleError(obj, vTemplate, vFailed, cause, header)

tName = obj.variables(vTemplate);
vName = obj.variables(vFailed);

id = sprintf('%s:couldNotAutocoupleVariable', header);
ME = MException(id, ['Cannot add the "%s" variable to %s because the dimensions ',...
    'of "%s" cannot be automatically coupled to match the "%s" variable. ',...
    'You may want to disable autocoupling for "%s".'], ...
    vName, obj.name, vName, tName, vName);
ME = addCause(ME, cause);
throwAsCaller(ME);

end