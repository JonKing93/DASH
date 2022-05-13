function[obj] = extract(obj, variables)

% Setup
header = "DASH:ensembleMetadata:extract";
dash.assert.scalarObj(obj, header);

% Check variables, get indices
v = obj.variableIndices(variables, true, header);

% Remove unselected variables
allVars = 1:obj.nVariables;
unspecified = allVars(~ismember(allVars, v));
obj = obj.remove(unspecified);

end