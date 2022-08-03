function[obj] = extract(obj, variables)
%% ensembleMetadata.extract  Limit ensemble metadata to specific variables
% ----------
%   obj = obj.extract(variableNames)
%   obj = obj.extract(v)
%   Updates the ensembleMetadata object to only include metadata for the
%   listed variables. All unlisted variables are removed from the
%   ensembleMetadata object.
% ----------
%   Inputs:
%       variableNames (string vector): The names of the variables to keep
%           in the ensembleMetadata object.
%       v (logical vector | vector, linear indices): The indices of the
%           variables to keep in the ensembleMetadata object. If a logical
%           vector, must have one element per variable in the state vector.
%
%   Outputs:
%       obj (scalar ensembleMetadata object): The ensembleMetadata object
%           with updated variables.
%   
% <a href="matlab:dash.doc('ensembleMetadata.extract')">Documentation Page</a>

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