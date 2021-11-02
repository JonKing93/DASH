function[] = removeAttributes(obj, varargin)
%% gridfile.removeAttributes  Remove attributes from the metadata of a gridded dataset
% ----------
%   obj.removeAttributes(fields)
%   obj.removeAttributes(field1, field2, .., fieldN)
%   Removes the listed fields from the metadata attributes of the current
%   gridMetadata object.
% ----------
%   Inputs:
%       fields (string vector): A list of fields to remove from the
%           metadata attributes.
%       fieldN (string scalar): The name of a field to remove from the
%           metadata attributes.
%
% <a href="matlab:dash.doc('gridfile.removeAttributes')">Documentation Page</a>

obj.meta = obj.meta.removeAttributes(varargin{:});

end
