function[obj] = autocouple(obj, variables, setting)
%% stateVector.autocouple  Set whether variables are automatically coupled to new variables in a state vector
% ----------
%   obj = obj.autocouple(v, setting)
%   obj = obj.autocouple(variableNames, setting)
%   Specify whether the indicated variables should be automatically coupled
%   to new variables added to the state vector.
%
%   Coupling is transitive, so any unlisted variables that are coupled
%   to the listed variables will also have their auto-coupling settings
%   updated.
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
setting = dash.parse.switches(setting, offOn, 1, 'setting', ...
    'recognized auto-coupling setting', header);

% Check variables, get indices
uv = obj.variableIndices(variables, true, header);

% Get the full set of coupled variables
[~, col] = find(obj.coupled(uv,:));
av = unique(col);

% Update
obj.autocouple_(av) = setting;

end