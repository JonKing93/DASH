function[obj] = extract(obj, variables)
%% stateVector.extract  Only include specified variables in a state vector
% ----------
%   obj = obj.extract(v)
%   obj = obj.extract(variableNames)
%   Extracts the specified variables from the state vector. All unspecified
%   variables are removed from the updated state vector.
% ----------
%   Inputs:
%       v (logical vector | linear indices): The indices of variables in
%           the state vector that should be extracted. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. 
%       variableNames (string vector): The names of variables in the state
%           vector that should be extracted. 
%
%   Outputs:
%       obj (scalar stateVector object): The state vector updated to only
%           include the extracted variables.
%
% <a href="matlab:dash.doc('stateVector.extract')">Documentation Page</a>

% Setup
header ="DASH:stateVector:extract";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Check variables, get indices
v = obj.variableIndices(variables, true, header);

% Remove all unspecified variables
allVars = 1:obj.nVariables;
unspecified = allVars(~ismember(allVars, v));
obj = obj.remove(unspecified);

end