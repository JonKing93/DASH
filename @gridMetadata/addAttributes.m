function[obj] = addAttributes(obj, varargin)
%% gridMetadata.addAttributes  Add non-dimensional attributes to the metadata for a gridded dataset
% ----------
%   obj = <strong>obj.addAttributes</strong>(field1, value1, field2, value2, .., fieldN, valueN)
%   Adds the named fields and associated values to the attributes structure
%   of a gridMetadata object.
% ----------
%   Inputs:
%       fieldN (string scalar): The name of a new field for the attributes
%           structure. Must be a valid Matlab variable name and cannot
%           duplicate any fields already in the attributes.
%       valueN: The value associated with the new attributes field.
%
%   Outputs:
%      obj (gridMetadata object): The updated gridMetadata object
%
% <a href="matlab:dash.doc('gridMetadata.addAttributes')">Documentation Page</a>

% Header for error IDs
header = "DASH:gridMetadata:addAttributes";

% Parse and error check input pairs
extraInfo = 'Inputs must be Attribute,Value pairs';
[names, values] = dash.assert.nameValue(varargin, 0, extraInfo, header);
dash.assert.uniqueSet(names, 'Attribute field', header);

% Require valid field names
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
error(id, ['Input %.f ("%s") cannot be used as an attributes field because it ',...
    'is not a valid Matlab variable name.'], inputIndex, name);
end
function[] = repeatedFieldNameError(names, isfield, header)
id = sprintf('%s:repeatedFieldName', header);
repeat = find(isfield, 1);
inputIndex = repeat*2-1;
error(id, 'Input %.f ("%s") is already a field in the attributes', ...
    inputIndex, names(repeat));
end