function[length] = length(obj, variables)

% Setup
header = "DASH:ensembleMetadata:length";
dash.assert.scalarObj(obj, header);

% Parse variables, return lengths
if ~exist('variables','var') || isequal(variables, 0)
    length = sum(obj.lengths);
else
    v = obj.variableIndices(variables, true, header);
    length = obj.lengths(v);
end

end