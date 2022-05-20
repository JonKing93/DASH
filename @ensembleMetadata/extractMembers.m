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