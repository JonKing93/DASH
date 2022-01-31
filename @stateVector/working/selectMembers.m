function[obj, nNew] = selectMembers(obj, nMembers, strict)

% Adjust for "all" option. Get the initial number of ensemble members
if strcmp(nMembers, 'all')
    nMembers = Inf;
end
nInitial = size(obj.subMembers{1}, 1);

% Get sets of coupled variables. Preallocate number of new ensemble members
sets = unique(obj.coupled, 'rows');
nSets = size(sets,1);
nNew = NaN(nSets, 1);
incomplete = false(nSets, 1);

% Cycle through sets
for s = 1:nSets
    vars = find(sets(s,:));

    % Get ensemble dimensions and sizes
    variable1 = obj.variables_(vars(1));
    [ensDims, ensSize] = variable1.dimensions('ensemble');
    nDims = numel(ensDims);

    % Initialize ensemble member selection
    subIndices = cell(1, nDims);
    subMembers = obj.subMembers{s};
    unused = obj.unused{s};
    nRemaining = numel(unused);
    nNew(s) = 0;

    % Select ensemble members until the ensemble is complete
    while nNew(s) < nMembers
        if nNew(s)+nRemaining<nMembers && ~isinf(nMembers)
            incomplete(s) = true;
        end

        % Throw error if cannot be completed
        if incomplete(s) && strict
            notEnoughMembersError(obj, vars, nMembers, nNew(s), nRemaining, header);
        end

        % Select members, remove from unselected members
        if incomplete(s) || isinf(nMembers)
            nSelected = nRemaining;
        else
            nSelected = nMembers - nNew(s);
        end
        members = unused(1:nSelected);
        unused(1:nSelected) = [];

        % Subscript members over ensemble dimensions. Add to full set of
        % saved ensemble members
        [subIndices{:}] = ind2sub(ensSize, members);
        newMembers = cell2mat(subIndices);
        subMembers = cat(1, subMembers, newMembers);

        % Remove overlapping ensemble members from variables that do no
        % allow overlap. (Remove new members when overlap occurs)
        for k = 1:numel(vars)
            v = vars(k);
            if ~obj.allowOverlap(v)
                variable = obj.variables_(v);
                subMembers = variable.removeOverlap(subMembers, ensDims);
            end
        end
        
        % Update sizes
        nNew(s) = size(subMembers,1) - nInitial;
        nRemaining = numel(unused);

        % If all members were selected, exit loop
        if incomplete(s) || isinf(nMembers)
            break
        end
    end

    % Require at least one ensemble member
    if nNew(s)==0
        noMembersError;
    end

    % Record the saved and unused ensemble members
    obj.unused{s} = unused;
    obj.subMembers{s} = subMembers;
end

% If there were incomplete ensembles, find the set of coupled variables
% with the smallest number of new ensemble members
if any(incomplete)
    [nNew, s] = min(nNew);
    vars = find(sets(s,:));

    % Trim each set of ensemble members to match this smaller number and
    % notify user of incomplete ensemble.
    for s = 1:nSets
        obj.subMembers{s} = obj.subMembers{s}(1:nInitial+nNew, :);
    end
    incompleteEnsembleWarning(obj, vars, nMembers, nNew, header);
end

% Return the total number of new ensemble members
nNew = nNew(1);

end