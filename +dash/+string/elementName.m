function[name] = elementName(index, listName, listLength)
%% dash.string.elementName  Return a name for an element in a list
% ----------
%   name = dash.string.elementName(index, listName, listLength)
%   Returns a name for an element in a list. If the list has a length of 1,
%   returns the name of the list. If the list has a length greater than 1,
%   refers to the element by its index in the list.
% ----------
%   Inputs:
%       index (scalar positive integer): The index of an element in a list
%       listName (string scalar): The name of the list
%       listLength (scalar positive integer): The length of the list
%
%   Outputs:
%       name (string scalar): A name to refer to the list element.
%
% <a href="matlab:dash.doc('dash.string.elementName')">Documentation Page</a>

name = listName;
if listLength > 1
    name = sprintf('Element %.f of %s', index, name);
end

end