function[obj] = autocouple(obj, setting, variables)
%% stateVector.autocouple  Set whether variables are automatically coupled to new variables in the state vector
% ----------
%   obj = obj.autocouple
%   Indicate that all variables currently in the state vector should be
%   automatically coupled to new variables added to the state vector.
%   Coupling is transitive, so all variables in the state vector will also
%   be coupled to one another.
%
%   obj = obj.autocouple(setting)
%   obj = obj.autocouple(true|"a"|"auto"|"automatic")
%   obj = obj.autocouple(false|"m"|"man"|"manual")
%   Indicate whether the variables in the state vector should be
%   automatically coupled to new variables or not. If indicating that the
%   current variables should automatically be coupled to new variables,
%   then the all variables currently in the state vector will also be
%   coupled to one another.
%
%   obj = obj.autocouple(setting, -1)
%   obj = obj.autocouple(setting, v)
%   obj = obj.autocouple(setting, variableNames)
%   Specify whether the listed variables should be automatically coupled to
%   new variables added to the state vector. Coupling is transitive, so
%   changes to autocouple settings can change the coupling status of other
%   variables in the state vector.
%
%   If you add variables to an existing set of autocoupled variables,
%   then the listed variables will be coupled to the existing autocoupled
%   variables. If there are no existing autocoupled variables, then the
%   first listed variable will be used as a coupling template.
%
%   If you remove variables from an existing set of autocoupled variables,
%   then the listed variables will be uncoupled from the remaining
%   variables in the autocoupling set. However, the formerly autocoupled
%   variables will remain coupled to one another.
%
%   obj = obj.autocouple(true, variables, t)
%   obj = obj.autocouple(true, variables, templateName)
%   Specify the coupling template to use when initializing a set of coupled
%   variables. This syntax can only be used when there are no previously
%   existing variables in an autocoupling set.
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
% <a href="matlab:dash.doc('stateVector.autocouple')">Documentation Page</a>

% Setup
header = "DASH:stateVector:autocouple";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Parse the setting
offOn = {["m","man","manual"], ["a","auto","automatic"]};
setToAuto = dash.parse.switches(setting, offOn, 1, 'setting', ...
    'recognized auto-coupling setting', header);

% Get variable indices
if ~exist('variables','var') || isempty(variables)
    variables = -1;
end
v = obj.variableIndices(variables, true, header);
v = unique(v);

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
    v = [t;v];
end

% Update autocoupling ass appropriate
if setToAuto
    obj = automatic(obj, v, header);
else
    obj = manual(obj, v);
end

% Update the autocouple setting
obj.autocouple_(v) = setToAuto;

end

% Utilities
function[obj] = manual(obj, vUser)

% Find variables that *were* in the autocouple set
vAuto = find(obj.autocouple_);
if ~isempty(vAuto)
    [changeStatus, loc] = ismember(vUser, vAuto);
    vChange = vUser(changeStatus);

    % Uncouple the remaining variables in the coupling set from those being
    % remove. However, maintain coupling between the removed variables
    vRemain = vAuto;
    vRemain(loc) = [];
    obj.coupled(vChange, vRemain) = false;
    obj.coupled(vRemain, vChange) = false;
end

end
function[obj] = automatic(obj, vUser, header)

% Find variables that *were not* in the autocouple set
vManual = find(~obj.autocouple_);
if ~isempty(vManual)
    changeStatus = ismember(vUser, vManual);
    vChange = vUser(changeStatus);
    nChange = numel(vChange);

    % Exit if nothing changed state
    if nChange == 0
        return
    end

    % Get the coupling template for autocoupled variables
    t = find(obj.autocouple_, 1);
    if isempty(t) && nChange==1
        return
    elseif isempty(t)
        t = vUser(1);
        start = 2;
    else
        start = 1;
    end

    % Couple variables that are changing state
    for k = start:nChange
        v = vChange(k);
        [obj, failed, cause] = obj.coupleDimensions(t, v, header);
        if failed
            ME = failedCouplingError(obj, t, v, cause, header);
            throwAsCaller(ME);
        end
    end
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
function[ME] = failedCouplingError(obj, t, v, cause, header)
vector = '';
if ~strcmp(obj.label, "")
    vector = sprintf('in %s ', obj.name);
end
template = obj.variableNames(t);
var = obj.variableNames(v);

id = sprintf('%s:couldNotCoupleVariable', header);
ME = MException(id, ['Cannot autocouple variable "%s" %sbecause %s cannot ',...
    'be coupled to the "%s" variable.'], var, vector, var, template);
ME = addCause(ME, cause);
end