function[length] = length(obj, variables)
%% ensembleMetadata.length  Return the lengths of a state vector and its variables
% ----------
%   length = <strong>obj.length</strong>
%   length = <strong>obj.length</strong>(0)
%   Return the total length of a state vector.
%
%   lengths = <strong>obj.length</strong>(variableNames)
%   lengths = <strong>obj.length</strong>(v)
%   lengths = <strong>obj.length</strong>(-1)
%   Returns the length of the specified variables in a state vector.
% ----------
%   Inputs:
%       v (0 | -1 | logical vector | vector, linear indices): Indicates
%           which state vector lengths to return. If 0, returns the length
%           of the total state vector. Otherwise, lists the indices of
%           variables whose lengths should be returned. If -1, selects all
%           variables in the state vector. If a logical vector, must have
%           one element per variable in the state vector. Otherwise, a
%           vector of linear indices.
%       variableNames (string vector [nVariables]): The names of the
%           variables in the state vector whose lengths should be returned
%
%   Outputs:
%       length (scalar positive integer): The length of the full state vector.
%       lengths (vector, positive integers [nVariables]): The lengths of
%           the specified variables in the state vector.
%
% <a href="matlab:dash.doc('ensembleMetadata.length')">Documentation Page</a>           

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