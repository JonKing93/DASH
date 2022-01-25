function[obj] = uncouple(obj, variables, verbose)
%% stateVector.uncouple  Allow variables to use different metadata when building ensemble members
% ----------
%   obj = obj.uncouple(v)
%   obj = obj.uncouple(variableNames)
%   Uncouple the specified variables from one another. Uncoupled variables
%   are not required to have matching metadata within an ensemble member.
%   
%   Coupling is transitive, so unlisted variables that are coupled to two
%   or more listed variables will also be uncoupled. If you have enable the
%   verbose option for the state vector, then the method will print a list
%   of these secondary uncoupled variables to the console. (See the
%   "stateVector.verbose" method to adjust state vector verbosity).
%
%   obj = obj.couple(variables, verbose)
%   Specify whether the method should print the list of secondary
%   uncoupled variables to the console. This syntax allows you to override
%   the state vector's default verbosity setting.
% ----------
%   Inputs:
%       v (logical vector | linear indices): The indices of variables in
%           the state vector that should be coupled. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices.
%       variableNames (string vector): The names of variables in the state
%           vector that should be coupled.
%       verbose (scalar logical | string scalar): Indicates whether the method
%           should print a list of secondary uncoupled variables to the console.
%           [true | "v" | "verbose"]: Print the list
%           [false | "q" | "quiet"]: Do not print the list
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated
%           uncoupled variables.
%
% <a href="matlab:dash.doc('stateVector.uncouple')">Documentation Page</a>

% Setup
header = "DASH:stateVector:uncouple";
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

% Get the sets of coupled variables
coupledSets = unique(obj.coupled, 'rows');
nSets = size(coupledSets, 1);

% Cycle through the coupling sets, get linear variable indices. Count the
% number of user-specified variables in the set.
for s = 1:nSets
    cv = find(coupledSets(s,:));
    isUserVar = ismember(cv, uv);

    % If there are 2+ user variables in the set, uncouple the entire set
    % (but maintain self coupling)
    if sum(isUserVar)>1
        obj.coupled(cv,:) = false;
        obj.coupled(1:obj.nVariables+1:end) = true;

        % Notify user of secondary variables
        if verbose
            sv = cv(~isUserVar);
            notifySecondaryUncoupling(sv);
        end
    end
end

end