function[obj] = couple(obj, variables)
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
%   of the listed variables will also be coupled.
% ----------
%   Inputs:
%       v (logical vector | linear indices): The indices of variables in
%           the state vector that should be coupled. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices.
%       variableNames (string vector): The names of variables
%           in the state vector that should be coupled.
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

% Check user variables, get indices
uv = obj.variableIndices(variables, true, header);

% Get the full set of variables being coupled.
[~, col] = find(obj.coupled(uv,:));
av = unique(col);

% Update coupled variables to match the template
tv = uv(1);
obj = obj.coupleDimensions(tv, av, header);

% Couple the variables
for k = 1:numel(av)
    obj.coupled(av, av(k)) = true;
    obj.coupled(av(k), av) = true;
end

end