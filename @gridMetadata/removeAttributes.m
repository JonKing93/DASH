function[obj] = removeAttributes(obj, varargin)
%% gridMetadata.removeAttributes  Remove attributes from the metadata of a gridded dataset
% ----------
%   obj = <strong>obj.removeAttributes</strong>(fields)
%   obj = <strong>obj.removeAttributes</strong>(field1, field2, .., fieldN)
%   Removes the listed fields from the metadata attributes of the current
%   gridMetadata object.
%
%   obj = <strong>obj.removeAttributes</strong>(0)
%   Removes all metadata attributes from the current gridMetadata object.
% ----------
%   Inputs:
%       fields (string vector): A list of fields to remove from the
%           metadata attributes.
%       fieldN (string scalar): The name of a field to remove from the
%           metadata attributes.
%
%   Outputs:
%       obj (gridMetadata object): The updated gridMetadata object
%
% <a href="matlab:dash.doc('gridMetadata.removeAttributes')">Documentation Page</a>

% Error ID header
header = "DASH:gridMetadata:removeAttributes";
dash.assert.scalarObj(obj, header);

% Get the attributes fields
[~, atts] = gridMetadata.dimensions;
attributes = obj.(atts);
fields = string(fieldnames(attributes));

% Parse the inputs
if numel(varargin)==0
    dash.error.notEnoughInputs;
elseif numel(varargin)==1 && isequal(varargin{1}, 0)
    remove = fields;
elseif numel(varargin)==1
    remove = dash.assert.strlist(varargin{1}, 'fields', header);
else
    remove = dash.parse.vararginFlags(varargin, 1, 0, header);
end

% Check the fields are in the attributes
listName = 'field in the attributes structure';
dash.assert.strsInList(remove, fields, 'Attributes field name', listName, header);

% Remove and update
attributes = rmfield(attributes, remove);
obj.(atts) = attributes;

end