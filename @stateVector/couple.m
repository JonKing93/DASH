function[obj] = couple(obj, variables, verbose)
%% stateVector.couple  Match variable metadata when building ensemble members
% ----------
%   obj = obj.couple(v)
%   obj = obj.couple(variableNames)
%   Couples the specified variables to one another. Coupled variables
%   are required to have matching metadata within ensemble members of a
%   state vector ensemble. This ensures that, within an ensemble member,
%   the data from multiple variables all refer to the same point. By
%   default, all variables in a state vector are coupled to one another.
%
%   When the ensemble dimensions of a variable are changed, the ensemble
%   dimensions of coupled variables will be updated to match. Note that
%   this update does not copy the reference/state indices across variables.
%   Only the status of a dimension as an ensemble/state dimension is
%   updated.
%
%   Coupling is transitive, so unlisted variables that are coupled to one
%   of the listed variables will also be coupled. If you have enabled the
%   verbose option for the state vector, then this method will print a
%   list of these secondary coupled variables to the console. (See the
%   "stateVector.verbose" method to adjust state vector verbosity).
%
%   obj = obj.couple(variables, verbose)
%   Specify whether the method should print the list of secondary coupled
%   variables to the console. This syntax allows you to override the state
%   vector's default verbosity setting. 
% ----------
%   Inputs:
%       v (logical vector | linear indices): The indices of variables in
%           the state vector that should be coupled. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices.
%       variableNames (string vector): The names of variables
%           in the state vector that should be coupled.
%       verbose (scalar logical | string scalar): Indicates whether the method
%           should print a list of secondary coupled variables to the console.
%           [true | "v" | "verbose"]: Print the list
%           [false | "q" | "quiet"]: Do not print the list
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated
%           coupled variables.
%
% <a href="matlab:dash.doc('stateVector.couple')">Documentation Page</a>

% Glossary of indices
%   uv: User specified variables
%   
%   sv: Secondary variables
%   Variables coupled to user variables, but not specified by the user.
%   Because coupling is transitive, these will also be coupled.
%
%   av: All variables being coupled
%   Includes both uv and sv.
%
%   tv: Template variable
%   This is the first user-specified variable. The ensemble dimensions of
%   the other variables will be updated to match this variable.

% Setup
header = "DASH:stateVector:couple";
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

% Check user variables, get indices
uv = obj.variableIndices(variables, true, header);

% Get the full set of variables being coupled.
[~, col] = find(obj.coupled(uv,:));
av = unique(col);

% Update coupled variables to match the template
tv = uv(1);
obj = obj.updateCoupledVariables(tv, av);

% Notify user of secondary coupling
if verbose
    sv = av(~ismember(av, uv));
    notifySecondaryCoupling(sv);
end

% Couple the variables
for k = 1:numel(av)
    obj.coupled(av, av(k)) = true;
    obj.coupled(av(k), av) = true;
end

end