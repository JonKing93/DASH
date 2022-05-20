function[metadata] = members(obj, dimension, members, variable)
%% ensembleMetadata.members  Return the metadata for ensemble members in a state vector ensemble
% ----------
%   metadata = obj.members(dimension)
%   Return metadata for each member of an ensemble. The metadata will have
%   one row per member in the ensemble. The first input indicates the
%   ensemble dimension for which to return metadata. If multiple variables
%   use the ensemble dimension, returns the metadata for the first variable
%   that uses the ensemble dimension.
%
%   metadata = obj.members(dimension, members)
%   metadata = obj.members(dimension, -1)
%   Returns metadata at the specified ensemble members. If the second input
%   is -1, selects all members in the ensemble. The returned metadata will
%   have one row per listed ensemble member.
%
%   metadata = obj.members(dimension, members, variableName)
%   metadata = obj.members(dimension, members, v)
%   Indicate which variable's metadata to return. The variable must use the
%   listed dimension as an ensemble dimension.
% ----------
%   Inputs:
%       dimension (string scalar | char row vector): The name of an ensemble dimension used
%           by a variable in the state vector.
%       members (-1 | logical vector | vector, linear indices): The indices
%           of ensemble members for which to return metadata. If -1, selects
%           all ensemble members in the state vector ensemble. If a logical
%           vector, must have one element per ensemble members in the
%           ensemble. Otherwise, a vector a linear indices. Note that these
%           indices refer to the columns (ensemble members) of the ensemble.
%       variableName (string scalar | char row vector): The name of the variable whose
%           ensemble dimension metadata should be used.
%       v (scalar linear index | logical vector): The index of the variable
%           whose ensemble dimension metadata should be used. If a logical
%           vector, must have one element per variable in the state vector
%           and exactly one true element.
%
%   Outputs:
%       metadata (matrix [nMembers x ?]): The metadata for the selected
%           ensemble members along the indicated ensemble dimension. Will
%           have one row per selected ensemble member.
%
% <a href="matlab:dash.doc('ensembleMetadata.members')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:members";
dash.assert.scalarObj(obj, header);
if obj.nMembers == 0
    noMembersError(obj, header);
end

% Check the dimension
dimension = dash.assert.strflag(dimension, 'dimension', header);

% Error check user variables. Get name and index.
if exist('variable','var') && ~isempty(variable)
    v = obj.variableIndices(variable, false, header);
    if numel(v)>1
        tooManyVariablesError(obj, v, header);
    end

    % Get the coupling set for the variable, require it uses the ensemble dimension
    s = obj.couplingSet(v);
    list = sprintf('ensemble dimension of the "%s" variable', obj.variables_(v));
    d = dash.assert.strsInList(dimension, obj.ensembleDimensions{s}, 'dimension', list, header);

% If there is no variable, search for one that uses the dimension
else
    for s = 1:obj.nSets
        [isdim, d] = ismember(dimension, obj.ensembleDimensions{s});
        if isdim
            break
        end
    end

    % Throw error if there is no variable
    if ~isdim
        noVariableError(obj, dimension, header);
    end
end

% Default and check members
if ~exist('members','var') || isequal(members, -1)
    members = 1:obj.nMembers;
else
    logicalReq = 'have one element per ensemble member';
    linearMax = 'the number of ensemble members';
    members = dash.assert.indices(members, obj.nMembers, 'members', logicalReq, linearMax, header);
end

% Get the metadata
metadata = obj.ensemble{s}{d}(members, :);

end

%% Error messages
function[] = noMembersError(obj, header)
id = sprintf('%s:noEnsembleMembers', header);
ME = MException(id, ['Cannot return ensemble member metadata for %s because the ',...
    'ensemble does not have any members.'], obj.name);
throwAsCaller(ME);
end
function[] = tooManyVariablesError(obj, v, header)
variables = obj.variables_(v);
variables = dash.string.list(variables);
id = sprintf('%s:tooManyVariables', header);
ME = MException(id, ['You must list exactly 1 variable, but you have specified ',...
    '%.f variables (%s).'], numel(v), variables);
throwAsCaller(ME);
end
function[] = noVariableError(obj, dimension, header)
id = sprintf('%s:noVariableUsesDimension', header);
ME = MException(id, 'None of the variables in %s use "%s" as an ensemble dimension', obj.name, dimension);
throwAsCaller(ME);
end