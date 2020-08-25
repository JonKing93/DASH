function[k] = checkStrsInList(input, list, name, listName )
%% Checks that an input is a set of strings that are all members of a list.
% Throws a custom error message if not. Returns the indices of the strings
% in the list.
%
% k = dash.checkStrsInList(input, list, name, listMessage)
%
% ----- Inputs -----
%
% input: The input being checked
%
% list: A list of allowed strings. A string vector.
%
% name: The name of the input. A string
%
% listName: Name of the list. A string

% Check the input is a string list
dash.assertStrList(input, name);
input = string(input);

% Check all strings are allowed. Get their indices in the list.
[inList, k] = ismember(input, list);
if any(~inList)
    bad = find(~inList,1);
    
    % Informative error message
    badName = name;
    if numel(input)>1
        badName = sprintf('Element %.f in %s (%s)', bad, name, input(bad));
    end
    error('%s is not a %s. Allowed values are %s.', badName, listName, dash.errorStringList(list));
end

end