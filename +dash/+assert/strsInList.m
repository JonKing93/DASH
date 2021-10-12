function[k] = strsInList(strings, list, name, listName, idHeader)
%% dash.assert.strsInList  Throw error if strings are not in a list of allowed strings
% ----------
%   k = dash.assert.strsInList(strings, list, name, listName, idHeader)
%   Checks if all the elements in strings are members of list. If not, throws
%   an error with custom message and identifier. If so, returns the indices
%   of each string in the list.
% ----------
%   Inputs:
%       strings (string vector)[nStrings]: The set of strings being checked
%       list (string vector): The set of allowed strings
%       name (string scalar): The name of strings in the calling function
%       listName (string scalar): The name of list in the calling function
%       idHeader (string scalar): A header for thrown error IDs
%
%   Outputs:
%       k (vector, linear indices)[nStrings]: The index of each element of
%           strings in the list of allowed values
%
%   Throws:
%       <idHeader>:stringsNotInList
%
%   <a href="matlab:dash.doc('dash.assert.strsInList')">Online Documentation</a>

% Check if in list, get linear indices
[inList, k] = ismember(strings, list);

% Throw error if any strings are not in list
if ~all(inList)
    bad = find(~inList, 1);
    
    % Reference the variable or element of strings by name
    if numel(strings)==1
        badName = name;
    else
        badName = sprintf('Element %.f in %s', bad, name);
    end
    
    % Error message
    id = sprintf('%s:stringNotInList', idHeader);
    allowed = dash.string.list(list);
    error(id, '%s (%s) is not a(n) %s. Allowed values are %s.',...
        badName, strings(bad), listName, allowed);
end

end