function[indices] = stringsOrIndices(input, strings, name, elementName, collectionName, listType, header)
%% dash.parse.stringsOrIndices  Parse inputs that are either a list of strings, or a vector of indices
% ----------
%   indices = dash.parse.stringsOrIndices(input, strings)
%   Parses an input that may either be a list of strings referencing
%   elements in a collection, or a vector of indices for elements in the
%   collection. Throws an error if the input not a valid reference to a
%   collection. If the input is valid, returns the linear indices of the
%   elements of the input within the collection.
% 
%   indices = dash.parse.stringsOrIndices(input, strings, name, elementName, collectionName, listType, header)
%   Customized error messages and IDs.
% ----------
%   Inputs:
%       input (any data type): The input being parsed.
%       strings (string vector [nElements]): The list of strings associated with
%           elements in a collection.
%       name (string scalar): The name of the input being parsed. Default
%           is "input"
%       elementName (string scalar): A name for a singular element in the
%           collection. Default is "element".
%       collectionName (string scalar): A name for the collection. Default
%           is "the collection"
%       listType (string scalar): A name for the type of list required when
%           the input is a string list. Default is "elements in the
%           collection".
%       header (string scalar): Header for thrown error IDs. Default is
%           "DASH:parse:stringsOrIndices".
%
%   Outputs:
%       indices (vector, linear indices): The linear indices of the input
%           elements within the collection.
%
% <a href="matlab:dash.doc('dash.parse.stringsOrIndices')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('elementName','var') || isempty(elementName)
    elementName = "element";
end
if ~exist('collectionName','var') || isempty(collectionName)
    collectionName = "the collection";
end
if ~exist('listType','var') || isempty(listType)
    listType = "elements in the collection";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:parse:stringsOrIndices";
end

% List of strings
try
    if dash.is.strlist(input)
        input = string(input);
        listName = sprintf('%s in %s', elementName, collectionName);
        indices = dash.assert.strsInList(input, strings, name, listName, header);
    
    % Vector of indices
    elseif isnumeric(input) || islogical(input)
        length = numel(strings);
        logicalRequirement = sprintf('have one element per %s in %s', elementName, collectionName);
        linearMax = sprintf('the number of %ss in %s', elementName, collectionName);
        indices = dash.assert.indices(input, length, name, logicalRequirement, linearMax, header);
    
    % Anything else
    else
        id = sprintf('%s:inputNeitherStringsNorIndices', header);
        error(id, ['%s must either be a list of %s, or a set of indices for %ss ', ...
            'in %s.'], name, listType, elementName, collectionName);
    end

% Minimize error stacks
catch ME
    throwAsCaller(ME);
end

end