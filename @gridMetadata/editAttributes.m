function[obj] = editAttributes(obj, fields, values, varargin)
%% gridMetadata.editAttributes  Replace non-dimensional attributes with new values
% ----------
%   obj = <strong>obj.editAttributes</strong>(fields, values)
%   Replaces the values of the named attribute fields with new values.
%
%   obj = <strong>obj.editAttributes</strong>(field1, value1, field2, value2, .., fieldN, valueN)
%   Uses a Name,Value syntax to edit attributes.
% ----------
%   Inputs:
%       attributeN (string scalar): The name of a field in the current
%           gridMetadata object's attributes structure.
%       valueN: The new value to use for the attribute.
%
%   Outputs:
%       obj (gridMetadata object): The updated gridMetadata object
%
% <a href="matlab:dash.doc('gridMetadata.editAttributes')">Documentation Page</a>

% Error header
header = "DASH:gridMetadata:editAttributes";
dash.assert.scalarObj(obj, header);

% Parse and error check inputs
if numel(varargin)>0
    varargin = [{fields}, {values}, varargin];
    extraInfo = 'Inputs must be Attributes-Field-Name,Value pairs';
    [names, values] = dash.assert.nameValue(varargin, 0, extraInfo, header);
else
    names = dash.assert.strlist(fields, 'fields', header);
end

% Get the attributes structure
[~, atts] = gridMetadata.dimensions;
attributes = obj.(atts);

% Require unique, recognized attribute fields
dash.assert.uniqueSet(names, 'Attributes field name', header);
fields = string(fieldnames(attributes));
dash.assert.strsInList(names, fields, 'Attributes field name', 'existing attribute field', header);

% Parse the field values
nEdit = numel(names);
values = dash.parse.inputOrCell(values, nEdit, 'values', header);

% Replace each value in the attributes
for n = 1:numel(names)
    attributes.(names(n)) = values{n};
end
obj.(atts) = attributes;

end