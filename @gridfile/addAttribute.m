function[obj] = addAttribute(obj, field, value)
%% gridfile.addAttribute  Add a non-dimensional attribute to gridfile metadata
% ----------
%   obj = obj.addAttribute(field, value)
%   Adds a non-dimensional attribute to gridfile metadata and returns the
%   updated gridfile object.
% ----------
%   Inputs:
%       field (string scalar): The name of the new metadata field in the
%           attributes struct. Must begin with a letter and consist only of
%           letters, numbers, and underscores. Cannot duplicate an existing
%           attribute field.
%       value: The new metadata values.
%
%   Outputs:
%       obj (gridfile object): The updated gridfile object
%
% <a href="matlab:dash.doc('gridfile.addAttribute')">Documentation Page</a>

% Header for error IDs
header = "DASH:gridfile:addAttribute";

% Get the current attributes
[~, attsName] = gridMetadata.dimensions;
atts = grid.meta.(attsName);

% Error check
field = dash.assert.strflag(field, 'field', header);
if ~isvarname(field)
    id = sprintf('%s:invalidFieldName', header);
    error(id, 'field must begin with a letter and consist only have letters, numbers, and underscores');
elseif ismember(field, fieldnames(atts))
    id = sprintf('%s:repeatedAttribute', header);
    error(id, 'The metadata attributes already have a "%s" field', field);
end

% Update
atts.(field) = value;
obj.meta = obj.meta.edit(attsName, atts);

end