function[index] = listOrIndices(input, strName, indexName, list, listName, lengthName, inputNumber, eltNames)
%% Parses inputs that can either be strings in a list or set of indices. Returns 
% the input as a set of linear indices.
%
% input: The input being parsed
%
% strName: The name of the input when a string list. A string.
%
% indexName: The name of the input when a set of indices. A string.
%
% list: The allowed values for strings. String vector.
%
% listName: The name of the list. A string
%
% lengthName: The name for the length. A string.
%
% inputNumber: Which input this is. A scalar integer.
%
% eltNames: The name of the elements in the list. A string.
%
% ----- Outputs -----
%
% index: Linear indices. If string inputs were provided, the indices of the
%    inputs in the list.

if dash.string.islist(input)
    index = dash.assert.strsInList(input, list, strName, listName);
elseif isnumeric(input) || islogical(input)
    index = dash.assert.indices(input, indexName, numel(list), lengthName);
else
    error('Input %.f must either be a list of %s, or a set of indices.', inputNumber, eltNames);
end

end