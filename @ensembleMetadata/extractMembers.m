function[obj] = extractMembers(obj, members)

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
    obj = obj.deleteSets;

% Otherwise, extract the selected members from each ensemble dimension
else
    for s = 1:obj.nSets
        dimensions = obj.ensembleDimensions{s};
        for d = 1:numel(dimensions)
            dimension = dimensions(d);
            currentMembers = obj.ensemble{s}.(dimension);
            obj.ensemble{s}.(dimension) = currentMembers(members, :);
        end
    end
end

end