function[attributes] = attributes(obj)
%% gridfile.attributes  Return the metadata attributes for a gridfile
% ----------
%   attributes = <strong>obj.attributes</strong>
%   Returns the metadata attributes for a gridfile object. Attributes are
%   organized in a scalar struct.
% ----------
%   Outputs:
%       attributes (scalar struct): Metadata attributes for the gridfile
%
% <a href="matlab:dash.doc('gridfile.attributes')">Documentation Page</a>

% Setup
header = "DASH:gridfile:attributes";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

% Get the attributes
[~, atts] = obj.meta.dimensions;
attributes = obj.meta.(atts);

end