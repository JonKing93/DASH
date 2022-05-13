function[obj] = append(obj, meta2, responseToRepeats)

% Setup
header = "DASH:ensembleMetadata:append";
dash.assert.scalarObj(obj, header);

% Check the second vector
dash.assert.scalarType(meta2, 'ensembleMetadata', 'The first input', header);
if ~isequal(obj.nMembers, meta2.nMembers)
    differentMembersError;
end

% Default and check response to repeated variables
if ~exist('responseToRepeats','var') || isempty(responseToRepeats)
    response = 0;
else
    response = dash.parse.switches(responseToRepeats, ...
        {["e","error"],["f","first"],["s","second"]}, 1, 'responseToRepeats', ...
        'allowed option', header);
end

% Check for repeats
vars2 = meta2.variables;
repeats = ismember(vars2, obj.variables);

% Process repeat variables
if any(repeats)
    repeats = vars2(repeats);
    if response==0
        repeatVariablesError;
    elseif response==1
        meta2 = meta2.remove(repeats);
    elseif response==2
        obj = obj.remove(repeats);
    end
end

% Append the variables from the second metadata object
obj.variables_ = [obj.variables; meta2.variables];
obj.lengths = [obj.lengths; meta2.lengths];

% Append state dimension metadata
for v = 1:numel(meta2.variables)
    variable = meta2.variables(v);
    dimensions = meta2.stateDimensions.(variable);
    for d = 1:numel(dimensions)
        dimension = dimensions(d);

        obj.state.(variable).(dimension) = meta2.state.(variable).(dimension);
    end
    obj.stateDimensions.(variable) = meta2.stateDimensions.(variable);
    obj.stateSize.(variable) = meta2.stateSize.(variable);
end

% Append the coupling sets
obj.couplingSet = [obj.couplingSet; obj.nSets+meta2.couplingSet];
obj.ensembleDimensions = [obj.ensembleDimensions; meta2.ensembleDimensions];
obj.ensemble = [obj.ensemble; meta2.ensemble];

% Update sizes
obj.nVariables = numel(obj.variables_);
obj.nSets = numel(obj.ensemble);

end
