function[obj] = autocouple(obj, setting, variables, template)
%% stateVector.autocouple  Set whether variables are automatically coupled to new variables in the state vector
% ----------
%   obj = <strong>obj.autocouple</strong>
%   Indicate that all variables currently in the state vector should be
%   automatically coupled to new variables added to the state vector.
%   Coupling is transitive, so all variables in the state vector will also
%   be coupled to one another.
%
%   obj = <strong>obj.autocouple</strong>(setting)
%   obj = <strong>obj.autocouple</strong>(true|"a"|"auto"|"automatic")
%   obj = <strong>obj.autocouple</strong>(false|"m"|"man"|"manual")
%   Indicate whether the variables in the state vector should be
%   automatically coupled to new variables or not. If indicating that the
%   current variables should automatically be coupled to new variables,
%   then the all variables currently in the state vector will also be
%   coupled to one another.
%
%   obj = <strong>obj.autocouple</strong>(setting, -1)
%   obj = <strong>obj.autocouple</strong>(setting, v)
%   obj = <strong>obj.autocouple</strong>(setting, variableNames)
%   Specify whether the listed variables should be automatically coupled to
%   new variables added to the state vector. Coupling is transitive, so
%   changes to autocouple settings can change the coupling status of other
%   variables in the state vector.
%
%   If you remove variables from a set of autocoupled variables, then the
%   listed variables will be uncoupled from the remaining variables in the
%   autocoupling set. However, the variables removed from the autocoupling
%   set will remain coupled to one another.
%
%   If you add variables to the set of autocoupled variables, then any
%   unlisted variables that are already coupled to the listed variables
%   will also be added to the set of autocoupled variables. If there are
%   already variables in the autocoupling set, then the new variables will
%   all be coupled to the existing autocoupled variables and will use the
%   existing autocoupled variables as a coupling template. If there are no
%   existing autocoupled variables, then the first listed variable will be
%   used as the coupling template.
%
%   obj = <strong>obj.autocouple</strong>(true, variables, t)
%   obj = <strong>obj.autocouple</strong>(true, variables, templateName)
%   Specify the coupling template to use when initializing a set of coupled
%   variables. This syntax can only be used when there are no previously
%   existing autocoupling variables.
% ----------
%   Inputs:
%       setting (scalar logical | string scalar): Whether the variables
%           should be automatically coupled to new variables.
%           [true|"a"|"auto"|"automatic"]: Automatically couple the variables
%           [false|"m"|"man"|"manual"]: Do not automatically couple the variables
%       v (logical vector | linear indices | -1): The indices of variables in
%           the state vector that should have their autocoupling settings
%           updated. A logical vector with one element per state vector
%           variable, or a vector of linear indices. If -1, selects all
%           variables in the state vector.
%       variableNames (string vector): The names of variables
%           in the state vector that should have their autocoupling
%           settings updated.
%       t (logical vector | linear index): The index of the variable that
%           should be used as the coupling template for a new set of
%           autocoupled variables.
%       templateName (string scalar): The name of a variable that should be
%           used as the coupling template for a new set of autocoupled
%           variables.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated
%           autocoupling settings.
%
% <a href="matlab:dash.doc('stateVector.autocouple')">Documentation Page</a>

% Setup
header = "DASH:stateVector:autocouple";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Parse the setting
if ~exist('setting','var') || isempty(setting)
    setting = 'auto';
end
offOn = {["m","man","manual"], ["a","auto","automatic"]};
setToAuto = dash.parse.switches(setting, offOn, 1, 'setting', ...
    'recognized auto-coupling setting', header);

% Get variable indices
if ~exist('variables','var')
    variables = -1;
elseif isempty(variables)
    variables = [];
end
v = obj.variableIndices(variables, true, header);

% Parse the template variable
if ~setToAuto && exist('template','var')
    dash.error.tooManyInputs;
elseif setToAuto && exist('template','var') && ~isempty(template)
    if any(obj.autocouple_)
        unallowedTemplateError(obj, header);
    end
    t = obj.variableIndices(template, true, header);
    t = unique(t);
    if numel(t) > 1
        tooManyTemplatesError(obj, t, header);
    end
    v = [t; v(:)];
end
v = unique(v, 'stable');

% Update autocoupling as appropriate
if setToAuto
    obj = automatic(obj, v, header);
else
    obj = manual(obj, v);
end

end

% Utilities
function[obj] = manual(obj, vUser)

% Find variables that *were* in the autocouple set
vAuto = find(obj.autocouple_);
if ~isempty(vAuto)
    [changeStatus, loc] = ismember(vUser, vAuto);
    vChange = vUser(changeStatus);
    loc(loc==0) = [];

    % Uncouple the remaining variables in the coupling set from those being
    % removed. However, maintain coupling between the removed variables
    vRemain = vAuto;
    vRemain(loc) = [];
    obj.coupled(vChange, vRemain) = false;
    obj.coupled(vRemain, vChange) = false;

    % Update autocoupling status
    obj.autocouple_(vChange) = false;
end

end
function[obj] = automatic(obj, vUser, header)

% Find variables being changed from manual to automatic
vManual = find(~obj.autocouple_);
if ~isempty(vManual)
    changeStatus = ismember(vUser, vManual);
    vChange = vUser(changeStatus);

    % Exit if nothing changed state
    if numel(vChange) == 0
        return
    end

    % Determine the coupling template
    alreadyAuto = find(obj.autocouple_);
    if ~isempty(alreadyAuto)
        t = alreadyAuto(1);
    else
        t = vUser(1);
    end

    % Find the complete set of variables changing to automatic
    [~, col] = find(obj.coupled(vChange,:));
    vChange = unique(col);

    % Couple variables to the template
    [obj, failed, cause] = obj.coupleDimensions(t, vChange, header);
    if failed
        ME = failedCouplingError(obj, t, failed, cause, header);
        throwAsCaller(ME);
    end
    obj.autocouple_(vChange) = true;

    % Record coupling status
    vAll = [alreadyAuto; vChange];
    obj.coupled(vAll, vAll) = true;
end

end

% Error messages
function[] = unallowedTemplateError(obj, header)

autoVars = find(obj.autocouple_);
autoVars = obj.variableNames(autoVars);

id = sprintf('%s:templateNotAllowed', header);
ME = MException(id, ['You cannot specify a autocoupling template variable ',...
    'for %s because %s already has autocoupled variables (%s).'], ...
    obj.name, obj.name, dash.string.list(autoVars));
throwAsCaller(ME);
end
function[] = tooManyTemplatesError(obj, t, header)

id = sprintf('%s:tooManyTemplates', header);
ME = MException(id, ['You can only specify a single variable as an autocoupling ',...
    'template, but you have specified %.f templates for %s.'], numel(t), obj.name);
throwAsCaller(ME);

end
function[ME] = failedCouplingError(obj, t, vFailed, cause, header)

tName = obj.variables(t);
vName = obj.variables(vFailed);

vector = '';
if ~strcmp(obj.label, "")
    vector = sprintf('in %s ', obj.name);
end

id = sprintf('%s:couldNotCoupleVariable', header);
ME = MException(id, ['Cannot autocouple variable "%s" %sbecause %s cannot ',...
    'be coupled to the "%s" template variable.'], vName, vector, vName, tName);
ME = addCause(ME, cause);

end