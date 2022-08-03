function[length] = length(obj, variables)
%% stateVector.length  Return the length of a state vector or variables in the vector
% ----------
%   length = <strong>obj.length</strong>
%   length = <strong>obj.length</strong>(0)
%   Return the number of elements in the state vector.
%
%   lengths = <strong>obj.length</strong>(-1)
%   Return the number of elements for each variable in the state vector.
%
%   lengths = <strong>obj.length</strong>(v)
%   lengths = <strong>obj.length</strong>(variableNames)
%   Return the number of elements for the specified variables in the state
%   vector.
% ----------
%   Inputs:
%       v (logical vector | vector, linear indices | 0 | -1): The indices
%           of the variables for which to return state vector lengths. If
%           0, returns the length of the entire state vector. If -1,
%           returns the lengths of every variable in the state vector.
%       variableNames (string vector): The names of the variables in the 
%           state vector for for which to return state vector lengths
%
%   Outputs:
%       length (scalar positive integer): The number of elements in the
%           state vector.
%       lengths (vector, positive integers): The number of state vector 
%           elements for each of the specified variables.
%
% <a href="matlab:dash.doc('stateVector.length')">Documentation Page</a>

% Setup
header = "DASH:stateVector:length";
dash.assert.scalarObj(obj, header);

% Parse variables and return lengths
if ~exist('variables','var') || isequal(variables,0)
    length = sum(obj.lengths);
else
    v = obj.variableIndices(variables, true, header);
    length = obj.lengths(v);
end

end