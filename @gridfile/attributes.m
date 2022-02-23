function[attributes] = attributes(obj)
%% gridfile.attributes  Return the metadata attributes for a gridfile
% ----------
%   <strong>obj.attributes</strong>
%   Prints metadata attributes to the console.
%
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

% Get the name of the attributes dimension
[~, atts] = obj.meta.dimensions;

% Print attributes to console
if nargout==0
    if numel(fieldnames(obj.meta.(atts)))==0
        fprintf('\n    The gridfile "%s" has no metadata attributes.\n\n', obj.name);
    else
        fprintf('\n    Metadata Attributes for gridfile "%s":\n', obj.name);
        obj.meta.dispAttributes;
    end

% Or return as output
else
    attributes = obj.meta.(atts);
end

end