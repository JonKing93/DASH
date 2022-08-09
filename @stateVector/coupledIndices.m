function[indexSets, nSets] = coupledIndices(obj)
%% stateVector.coupledIndices  Return sets of coupled variable indices
% ----------
%   [indexSets, nSets] = <strong>obj.coupledIndices</strong>
%   Returns the variable indices for sets of coupled variables in a state
%   vector. Also returns the total number of coupling sets.
% ----------
%   Outputs:
%       indexSets (cell vector {linear indices}): A cell vector with one
%           element per set of coupled variablesr. Each element holds the
%           linear indices of the variables within the coupling set.
%       nSets (scalar integer): The number of coupling sets in the state vector.
%
% <a href="matlab:dash.doc('stateVector.coupledIndices')">Documentation Page</a>

% Get the sets of coupled variables
sets = unique(obj.coupled, 'rows', 'stable');
nSets = size(sets, 1);

% Get the variable indices for each set
indexSets = cell(nSets,1);
for s = 1:nSets
    indexSets{s} = find(sets(s,:))';
end

end
