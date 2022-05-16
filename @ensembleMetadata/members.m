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
%   metadata = obj.members(dimension, members, variable)
%   Indicate which variable's metadata to return. The variable must use the
%   listed dimension as an ensemble dimension.
% ----------

% Setup
header = "DASH:ensembleMetadata:members";
dash.assert.scalarObj(obj, header);
if obj.nMembers == 0
    noMembersError;
end

% Check the dimension
dimension = dash.assert.strflag(dimension, 'dimension', header);

% Error check user variables. Get name and index.
if exist('variable','var') && ~isempty(variable)
    v = obj.variableIndices(variable, false, header);
    if numel(v)>1
        tooManyVariablesError;
    end

    % Get the coupling set for the variable, require it uses the ensemble dimension
    s = obj.couplingSet(v);
    ensembleDimensions = obj.ensembleDimensions{s};
    if ~ismember(dimension, ensembleDimensions)
        notEnsembleDimensionError;
    end

% If there is no variable, search for one that uses the dimension
else
    foundSet = false;
    for s = 1:obj.nSets
        if ismember(dimension, obj.ensembleDimensions{s})
            foundSet = true;
            break
        end
    end

    % Throw error if there is no variable
    if ~foundSet
        noSetError;
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
metadata = obj.ensemble{s}.(dimension)(members, :);

end