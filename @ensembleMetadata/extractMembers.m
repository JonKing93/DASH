function[obj] = extractMembers(obj, members)
%% ensembleMetadata.extractMembers  Limit ensemble metadata to specific ensemble members
% ----------
%   obj = <strong>obj.extractMembers</strong>(members)
%   Updates an ensemble metadata object to only include the specified
%   members. All unlisted members are removed from the ensembleMetadata
%   object.
% ----------
%   Inputs:
%       members (logical vector | vector, linear indices): The indices of
%           the current ensemble members to keep in the metadata. If a
%           logical vector, must have one element per ensemble member
%           currently in the ensembleMetadata object. If linear indices
%           with repeated elements, the ensemble members will be repeated
%           in the updated object.
%
%   Outputs:
%       obj (scalar ensembleMetadata object): The ensembleMetadata object
%           with udpated ensemble members.
%
% <a href="matlab:dash.doc('ensembleMetadata.extractMembers')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:extractMembers";
dash.assert.scalarObj(obj, header);

% Check members
logicalReq = 'have one element per ensemble member';
linearMax = 'the number of ensemble members';
members = dash.assert.indices(members, obj.nMembers, 'members', logicalReq, linearMax, header);

% Update size
nMembers = numel(members);
obj.nMembers = nMembers;

% If extracting nothing, remove the coupling sets
if obj.nMembers == 0
    obj.nSets = 0;
    obj.couplingSet = NaN(0,1);
    obj.ensembleDimensions = cell(0,1);
    obj.ensemble = cell(0,1);

% Otherwise, extract the selected members from each ensemble dimension
else
    for s = 1:obj.nSets
        dimensions = obj.ensembleDimensions{s};
        for d = 1:numel(dimensions)
            currentMembers = obj.ensemble{s}{d};
            obj.ensemble{s}{d} = currentMembers(members, :);
        end
    end
end

end