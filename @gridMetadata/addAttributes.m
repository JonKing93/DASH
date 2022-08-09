function[obj] = addAttributes(obj, varargin)
%% gridMetadata.addAttributes  Add non-dimensional attributes to the metadata for a gridded dataset
% ----------
%   obj = <strong>obj.addAttributes</strong>(fields, values)
%   Adds the named fields and associated values to the attributes structure
%   of a gridMetadata object.
%
%   obj = <strong>obj.addAttributes</strong>(field1, value1, field2, value2, .., fieldN, valueN)
%   Uses a Name,Value syntax to add attributes
% ----------
%   Inputs:
%       fields (string vector [nFields]): A list of fields to add to the
%           attributes structure.
%       values (cell vector [nFields]): The values associated with each
%           new attributes field.
%       fieldN (string scalar): The name of a new field for the attributes
%           structure. Must be a valid Matlab variable name and cannot
%           duplicate any fields already in the attributes.
%       valueN (any data type): The value associated with the new attributes field.
%
%   Outputs:
%       obj (gridMetadata object): The updated gridMetadata object
%
% <a href="matlab:dash.doc('gridMetadata.addAttributes')">Documentation Page</a>

% Header for error IDs
header = "DASH:gridMetadata:addAttributes";
dash.assert.scalarObj(obj, header);

% Parse inputs
extraInfo = 'Inputs must be Attributes-Field-Name,Value pairs';
[names, values] = dash.parse.nameValueOrCollection(varargin, ...
    'fields', 'values', extraInfo, header);

% Require valid, unique field names
dash.assert.uniqueSet(names, 'Attributes field name', header);
for n = 1:numel(names)
    if ~isvarname(names(n))
        invalidFieldNameError(names(n), n, header);
    end
end

% Get attributes structure
[~, atts] = gridMetadata.dimensions;
attributes = obj.(atts);

% Prevent repeated fields
fields = string(fieldnames(attributes));
isfield = ismember(names, fields);
if any(isfield)
    repeatedFieldNameError(names, isfield, header);
end

% Add each new value to the attributes
for n = 1:numel(names)
    attributes.(names(n)) = values{n};
end
obj.(atts) = attributes;

end

% Long error messages
function[] = invalidFieldNameError(name, index, header)
id = sprintf('%s:invalidFieldName', header);
inputIndex = index*2-1;
ME = MException(id, ['Attributes field name %.f ("%s") cannot be used as an attributes field because it ',...
    'is not a valid Matlab variable name.'], inputIndex, name);
throwAsCaller(ME);
end
function[] = repeatedFieldNameError(names, isfield, header)
id = sprintf('%s:repeatedFieldName', header);
repeat = find(isfield, 1);
inputIndex = repeat*2-1;
ME = MException(id, 'Attributes field name %.f ("%s") is already a field in the attributes', ...
    inputIndex, names(repeat));
throwAsCaller(ME);
end