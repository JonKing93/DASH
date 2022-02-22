function[] = removeAttributes(obj, varargin)
%% gridfile.removeAttributes  Remove attributes from the metadata of a gridded dataset
% ----------
%   <strong>obj.removeAttributes</strong>(fields)
%   <strong>obj.removeAttributes</strong>(field1, field2, .., fieldN)
%   Removes the listed fields from the metadata attributes of the current
%   gridMetadata object.
%
%   <strong>obj.removeAttributes</strong>(0)
%   Removes all attributes from the gridfile metadata.
% ----------
%   Inputs:
%       fields (string vector): A list of fields to remove from the
%           metadata attributes.
%       fieldN (string scalar): The name of a field to remove from the
%           metadata attributes.
%
% <a href="matlab:dash.doc('gridfile.removeAttributes')">Documentation Page</a>

% Setup
header = "DASH:gridfile:removeAttributes";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

obj.meta = obj.meta.removeAttributes(varargin{:});
obj.save;

end
