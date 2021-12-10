function[obj] = editAttributes(obj, varargin)
%% gridMetadata.editAttributes  Replace non-dimensional attributes with new values
% ----------
%   obj = <strong>obj.editAttributes</strong>(attribute1, value1, attribute2, value2, .., attributeN, valueN)
%   Replaces the values of the named attributes with new values.
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

% Parse and error check input pairs
extraInfo = 'Inputs must be Attribute,Value pairs';
[names, values] = dash.assert.nameValue(varargin, 0, extraInfo, header);
dash.assert.uniqueSet(names, 'Attribute field', header);

% Get the attributes structure
[~, atts] = gridMetadata.dimensions;
attributes = obj.(atts);

% Require recognzied attribute fields
fields = string(fieldnames(attributes));
dash.assert.strsInList(names, fields, 'Attribute name', 'existing attribute field', header);

% Replace each value in the attributes
for n = 1:numel(names)
    attributes.(names(n)) = values{n};
end
obj.(atts) = attributes;

end