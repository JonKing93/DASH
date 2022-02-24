function[indexSets, nSets] = coupledIndices(obj)
%% stateVector.coupledIndices  Return sets of coupled variable indices

sets = unique(obj.coupled, 'rows', 'stable');
nSets = size(sets, 1);

indexSets = cell(nSets,1);
for s = 1:nSets
    indexSets{s} = find(sets(s,:));
end

end
