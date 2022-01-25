function[obj] = add(obj, variableNames, grids, autocouple, verbose)
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
%
%   obj = obj.add(..., autocouple, verbose)
%   Specify whether the method should print a list of auto-coupled
%   variables to the console when auto-coupling occurs. If unset, follows
%   uses the verbosity setting of the state vector.
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
%           gridfile object, or the filepath to a .grid file.
%       grids (vector [nVariables], string | gridfile | cell {string | gridfile}):
%           The collection of .grid files that contain the data for the new variables.
%           Must have one element per new variable. May either be a vector
%           of gridfile objects, .grid filepaths, or a cell vector with
%           elements of either type.
%       autocouple (vector [nVariables], logical | string): Indicates the
%           autocoupling setting to use for each new variable. If
%           autocouple has a single element, applies the same setting to
%           all the new variables.
%           [true|"a"|"auto"|"automatic" (Default)]: Automatically couple new variable
%               to existing, auto-couple enabled variables.
%           [false|"m"|"man"|"manual"]: Disable autocoupling for the new variable
%       verbose (scalar logical | string scalar): Indicates whether the method
%           should print a list of auto-coupled variables to the console.
%           [true | "v" | "verbose"]: Print the list
%           [false | "q" | "quiet"]: Do not print the list
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

% Error check the names of the new variables
vars = dash.assert.strlist(variableNames, 'variableNames', header);
vars = vars(:);
obj.assertValidNames(vars, header);
nVariables = numel(vars);

% Default, error check autocoupling options
if ~exist('autocouple','var') || isempty(autocouple)
    autocouple = true;
end
offOn = {["m","man","manual"], ["a","auto","autocouple"]};
autocouple = dash.parse.switches(autocouple, offOn, nVariables, ...
    'autocouple', 'recognized auto-coupling option', header);

% Default, error check verbosity
if ~exist('verbose','var') || isempty(verbose)
    verbose = obj.verbose;
else
    offOn = {["q","quiet"], ["v","verbose"]};
    verbose = dash.parse.switches(verbose, offOn, 1, ...
        'verbose', 'recognized verbosity setting', header);
end

% Parse string grids
if dash.is.strlist(grids)
    grids = string(grids);
end

% If not scalar, grids must be a vector with one element per variable. If
% scalar, use the single grid for all variables
nGrids = numel(grids);
if nGrids > 1
    dash.assert.vectorTypeN(grids, [], nVariables, 'grids', header);
    gridIndices = (1:nVariables)';
else
    gridIndices = ones(nVariables, 1);
end

% If not a cell, require string list or gridfile vector.
if ~isa(grids, 'cell')
    if ~isa(grids, 'gridfile') && ~dash.is.strlist(grids)
        invalidGridsTypeError;
    end

    % Convert to cell column vector
    if nGrids>1 && isrow(grids)
        grids = grids';
    end
    grids = mat2cell(grids, ones(nGrids,1), 1); %#ok<MMTC> 
end

% Convert filepaths to gridfile objects. Informative error if failed.
for g = 1:nGrids
    if dash.is.strflag(grids{g})
        try
            grids{g} = gridfile(grids{g});
        catch ME
            gridfileFailedError(obj, vars, grids, g, ME, header);
        end
    end
end



% Add each new state vector variable
for v = 1:nVariables
    g = gridIndices(v);
    newVariable = dash.stateVectorVariable(grids{g});
    obj.variables_ = [obj.variables_; newVariable];
end

% Update variable properties
v = obj.nVariables + (1:nVariables);
obj.variableNames(v) = vars;
obj.allowOverlap(v) = false;
obj.nVariables = v(end);

% Add self coupling to new variables
obj.coupled(v,:) = false;
obj.coupled(:,v) = false;
obj.coupled(1:obj.nVariables+1:end) = true;

% Update autocoupling and couple variables
obj.autocouple_(v) = autocouple;
if any(autocouple)
    autoVars = obj.variables(obj.autocouple_);
    obj = obj.couple(autoVars);
end

% Notify autocoupling
if verbose
    notifyAutocoupling;
end

end

% Error messages
function[] = gridfileFailedError(obj, vars, grids, g, cause, header)

var = vars(g);
file = grids{g};

id = sprintf('%s:couldNotBuildGridfile', header);
ME = MException(id, ['Could not add variable "%s" to %s because the gridfile ',...
    'for the variable could not be built.\nFile: %s'], ...
    var, obj.name, file);
ME = addCause(ME, cause);
throwAsCaller(ME);

end