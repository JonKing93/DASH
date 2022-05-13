function[obj] = remove(obj, variables)

% Setup
header = "DASH:ensembleMetadata:remove";
dash.assert.scalarObj(obj, header);

% Get variable indices
v = obj.variableIndices(variables, true, header);

% Remove variables
removed = obj.variables_(v);
obj.variables_(v,:) = [];
obj.lengths(v,:) = [];

obj.stateDimensions = rmfield(obj.stateDimensions, removed);
obj.stateSize = rmfield(obj.stateSize, removed);
obj.state = rmfield(obj.state, removed);

% Remove the coupling set indices
sets = obj.couplingSet(v);
obj.couplingSet(v,:) = [];

% Cycle through the unique coupling sets of removed variables
sets = unique(sets);
for k = 1:numel(sets)
    s = sets(k);

    % Remove sets for which no variables remain
    if ~any(obj.couplingSet == s)
        obj.nSets = obj.nSets - 1;
        obj.ensembleDimensions(s,:) = [];
        obj.ensemble(s,:) = [];

        % Update set indices
        update = sets>s;
        sets(update) = sets(update) - 1;
        update = obj.couplingSet > s;
        obj.couplingSet(update) = obj.couplingSet(update) - 1;
    end
end

% Update sizes
obj.nVariables = numel(obj.variables_);
obj.nSets = numel(obj.ensemble);
if obj.nSets == 0
    obj.nMembers = 0;
end

end
    
