function[name] = elementName(index, listName, listLength)
%% dash.string.elementName  Returns an identifying name for an element in a list
% ----------
%   name = dash.string.elementName(index, listName, listLength)
%   Returns a name for an element in a list. If the list has a single
%   element, returns the name of the list. If the list contains multiple
%   elements, references the index of the named element.
% ----------
%   Inputs:
%       index (scalar positive integer): The index of an element in a list
%       listName (string scalar): The name of a the list
%       listLength (scalar positive integer): The number of elements in the list
%
%   Outputs:
%       name (char row vector): An identifying name for the indicated element
%
% <a href="matlab:dash.doc('dash.string.elementName')">Documentation Page</a>

name = listName;
if listLength>1
    name = sprintf('%s %.f', name, index);
end

end