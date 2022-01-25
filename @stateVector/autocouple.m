function[obj] = autocouple(obj, variables, setting, verbose)
%% stateVector.autocouple  Set whether variables are automatically coupled to new variables in a state vector
% ----------
%   obj = obj.autocouple(v, setting)
%   obj = obj.autocouple(variableNames, setting)
%   Specify whether the indicated variables should be automatically coupled
%   to new variables added to the state vector.
%
%   Coupling is transitive, so any unlisted variables that are coupled
%   to the listed variables will also have their auto-coupling settings
%   updated. If you have enabled the verbose option for the state vector,
%   then this method will print a list of these secondary updated variables
%   to the console. (See the "stateVector.verbose" method to adjust state
%   vector verbosity settings).
%
%   obj = obj.autocouple(v, true|"a"|"auto"|"automatic")
%   obj = obj.autocouple(variableNames, true|"a"|"auto"|"automatic")
%   Automatically couple the indicated variables to new variables added to
%   the state vector. This is the default behavior for all state vector
%   variables.
%
%   obj = obj.autocouple(v, false|"m"|"man"|"manual")
%   obj = obj.autocouple(variableNames, false|"m"|"man"|"manual")
%   Disable auto-coupling for the indicated variables. These variables will
%   not be coupled to new variables added to the state vector.
%
%   obj = obj.autocouple(..., verbose)
%   Specify whether the method should print the list of secondary updated
%   variables to the console. This syntax allows you to override the state 
%   vector's default verbosity setting. (See also the "stateVector.verbose"
%   method to alter a state vector's default verbosity.).
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
%       verbose (scalar logical | string scalar): Indicates whether the method
%           should print a list of secondary uncoupled variables to the console.
%           [true | "v" | "verbose"]: Print the list
%           [false | "q" | "quiet"]: Do not print the list
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

% Default, error check verbosity
if ~exist('verbose','var') || isempty(verbose)
    verbose = obj.verbose;
else
    offOn = {["q","quiet"], ["v","verbose"]};
    verbose = dash.parse.switches(verbose, offOn, 1, ...
        'verbose', 'recognized verbosity setting', header);
end

% Parse, error check autocouple setting
offOn = {["m","man","manual"], ["a","auto","automatic"]};
setting = dash.parse.switches(setting, offOn, 1, 'setting', ...
    'recognized auto-coupling setting', header);

% Check variables, get indices
uv = obj.variableIndices(variables, true, header);

% Get the full set of coupled variables
[~, col] = find(obj.coupled(uv,:));
av = unique(col);

% Notify user of secondary autocoupling update
if verbose
    sv = av(~ismember(av, uv));
    notifySecondaryAutocoupling(sv);
end

% Update
obj.autocouple_(av) = setting;

end