function[k] = strsInList(strings, list, name, listName, idHeader)
%% dash.assert.strsInList  Throw error if strings are not in a list of allowed strings
% ----------
%   k = dash.assert.strsInList(strings, list)
%   Checks if all elements in strings are members of list. If not, throws
%   an error. If so, returns the indices of each string in the list.
%
%   k = dash.assert.strsInList(strings, list, name, listName)
%   Use custom names for the strings and list in the thrown error message.
%
%   k = dash.assert.strsInList(strings, list, name, listName, idHeader)
%   Use a custom header in thrown error IDs.
% ----------
%   Inputs:
%       strings (string vector)[nStrings]: The set of strings being checked
%       list (string vector): The set of allowed strings
%       name (string scalar): The name of strings in the calling function.
%           Default is "strings"
%       listName (string scalar): The name of list in the calling function.
%           Default is "value in the list"
%       idHeader (string scalar): A header for thrown error IDs. 
%           Default is "DASH:assert:strsInList"
%
%   Outputs:
%       k (vector, linear indices)[nStrings]: The index of each element of
%           strings in the list of allowed values
%
%   Throws:
%       <idHeader>:stringsNotInList
%
%   <a href="matlab:dash.doc('dash.assert.strsInList')">Online Documentation</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "strings";
end
if ~exist('listName','var') || isempty(listName)
    listName = "value in the list";
end
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:assert:strsInList";
end

% Check if in list, get linear indices
[inList, k] = ismember(strings, list);

% Throw error if any strings are not in list
if ~all(inList)
    bad = find(~inList, 1);
    name = dash.string.elementName(bad, name, numel(strings));
    
    % Error message
    id = sprintf('%s:stringNotInList', idHeader);
    allowed = dash.string.list(list);
    ME = MException(id, '%s ("%s") is not a(n) %s. Allowed values are %s.',...
        name, strings(bad), listName, allowed);
    throwAsCaller(ME);
end

end