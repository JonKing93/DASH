function[attributes] = attributes(obj)
%% gridfile.attributes  Return the metadata attributes for a gridfile
% ----------
%   attributes = <strong>obj.attributes</strong>
%   Returns the metadata attributes for a gridfile object. Attributes are
%   organized in a scalar struct.
% ----------
%   Outputs:
%       attributes (scalar struct | []): Metadata attributes for the
%           gridfile. If the gridfile has no metadata attributes, returns
%           an empty array.
%
% <a href="matlab:dash.doc('gridfile.attributes')">Documentation Page</a>

% Setup
header = "DASH:gridfile:attributes";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

% Get attributes
[~, atts] = obj.meta.dimensions;
attributes = obj.meta.(atts);

% Return empty array if no attributes
if numel(fieldnames(attributes))==0
    attributes = [];
end

end