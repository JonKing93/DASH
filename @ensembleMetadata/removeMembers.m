function[obj] = removeMembers(obj, members)

% Setup
header = "DASH:ensembleMetadata:removeMembers";
dash.assert.scalarObj(obj, header);

% Check members
logicalReq = 'have one element per ensemble member';
linearMax = 'the number of ensemble members';
members = dash.assert.indices(members, obj.nMembers, 'members', logicalReq, linearMax, header);
members = unique(members);

% Update size
nRemoved = numel(members);
obj.nMembers = obj.nMembers - nRemoved;

% If removing everything, reset coupling sets
if obj.nMembers==0
    obj = obj.deleteSets;

% Otherwise, remove the selected members from each ensemble dimension
else
    for s = 1:obj.nSets
        dimensions = obj.ensembleDimensions{s};
        for d = 1:numel(dimensions)
            obj.ensemble{s}{d}(members,:) = [];
        end
    end
end

end

