function[obj] = autocouple(obj, variables, setting)
%% stateVector.autocouple  Set whether variables are automatically coupled to new variables in a state vector
% ----------
%   obj = obj.autocouple(v, setting)
%   obj = obj.autocouple(variableNames, setting)
%   Specify whether the indicated variables should be automatically coupled
%   to new variables added to the state vector. Coupling is transitive, so
%   changes to autocouple settings can change the coupling status of
%   variables in the state vector.
%
%   If new variables are added to the set of autocoupled variables, the new
%   variables will be coupled to the existing autocoupled variables. If
%   there are no existing autocoupled variables, then the new autocoupled
%   variables will be coupled to the first specified variable.
%
%   If variables are removed from the set of autocoupled variables, the
%   removed variables will be uncoupled from the remaining autocoupled
%   variables.
% ----------
%   Inputs:
%       v (logical vector | linear indices): The indices of variables in
%           the state vector that should be coupled. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices.
%       variableNames (string vector): The names of variables
%           in the state vector that should be coupled.
%       setting (scalar logical | string scalar): Whether the variables
%           should be automatically coupled to new variables.
%           [true|"a"|"auto"|"automatic"]: Automatically couple the variables
%           [false|"m"|"man"|"manual"]: Do not automatically couple the variables
% 
%   Outputs:
%       obj (scalar stateVector object): The state vector updated with the
%           new auto-coupling settings.
%
% <a href="matlab:dash.doc('stateVector.autocouple')">Documentation Page</a>

% Setup
header = "DASH:stateVector:autocouple";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Parse, error check autocouple setting
offOn = {["m","man","manual"], ["a","auto","automatic"]};
autoSetting = dash.parse.switches(setting, offOn, 1, 'setting', ...
    'recognized auto-coupling setting', header);

% Check variables, get indices
vUser = obj.variableIndices(variables, true, header);
vUser = unique(vUser);

% Update coupling status as appropriate
if ~autoSetting
    obj = manual(obj, vUser);
else
    [obj] = automatic(obj, vUser, header);
end

% Update setting
obj.autocouple_(vUser) = autoSetting;

end

% Utilities
function[obj] = manual(obj, vUser)

% Find variables that *were* in the autocouple set
vAuto = find(obj.autocouple_);
if ~isempty(vAuto)
    [changeStatus, loc] = ismember(vUser, vAuto);
    vChange = vUser(changeStatus);

    % Uncouple the remaining variables in the coupling set from the
    % variables that are being removed.
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

    % Check for coupling templates
    t = find(obj.autocouple_, 1);
    if isempty(t) && nChange==1
        return
    elseif isempty(t)
        t = vChange(1);
        start = 2;
    else
        start = 1;
    end

    % Couple variables that are changing state
    for k = start:nChange
        v = vChange(k);
        [obj, failed, cause] = obj.coupleDimensions(t, v, header);
        if failed
            failedCouplingError;
        end
    end
end

end

% Error message
function[] = failedCouplingError(obj, vUser, cause, header)

var = 'variables';
if numel(vUser)==1
    var = 'variable';
end
vector = '';
if ~strcmp(obj.label, "")
    vector = sprintf('in %s ', obj.name);
end

id = sprintf('%s:couldNotCoupleVariable', header);
ME = MException(id, ['Cannot autocouple the specified %s %sbecause the %s ',...
 




