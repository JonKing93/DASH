function[obj] = couple(obj, variables)
%% stateVector.couple  Match variable metadata when building ensemble members
% ----------
%   obj = obj.couple
%   obj = obj.couple(-1)
%   Couples all the variables in the state vector to one another. Coupled variables
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
%   obj = obj.couple(v)
%   obj = obj.couple(variableNames)
%   Couples the specified variables to one another. 
%   Coupling is transitive, so unlisted variables that are coupled to one
%   of the listed variables will also be coupled.
% ----------
%   Inputs:
%       v (logical vector | linear indices | -1): The indices of variables in
%           the state vector that should be coupled. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If -1, selects all variables in the state
%           vector.
%       variableNames (string vector): The names of variables
%           in the state vector that should be coupled.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated
%           coupled variables.
%
% <a href="matlab:dash.doc('stateVector.couple')">Documentation Page</a>

% Setup
header = "DASH:stateVector:couple";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Check user variables, get indices
if ~exist('variables','var')
    variables = -1;
end
vUser = obj.variableIndices(variables, true, header);

% Get the full set of variables being coupled.
[~, col] = find(obj.coupled(vUser,:));
vAll = unique(col);

% Update coupled variables to match the template
vTemplate = vUser(1);
[obj, failed, cause] = obj.coupleDimensions(vTemplate, vAll, header);
if failed
    couplingFailedError(obj, vTemplate, failed, cause, header);
end

% Record coupling status
obj.coupled(vAll, vAll) = true;

end

% Error message
function[] = couplingFailedError(obj, vTemplate, vFailed, cause, header)

tName = obj.variables(vTemplate);
vName = obj.variables(vFailed);

vector = '';
if ~strcmp(obj.label, "")
    vector = sprintf('in %s ', obj.name);
end

id = sprintf('%s:couldNotCoupleVariable', header);
ME = MException(id, ['Could not couple the "%s" variable to the "%s" variable %s',...
    'because the dimensions of "%s" could not be updated to match "%s".'],...
    vName, tName, vector, vName, tName);

ME = addCause(ME, cause);
throwAsCaller(ME);

end