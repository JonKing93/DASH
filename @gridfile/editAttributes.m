function[] = editAttributes(obj, varargin)
%% gridfile.editAttributes  Change existing metadata attributes
% ----------
%   <strong>obj.editAttributes</strong>(field1, value1, field2, value2, .., fieldN, valueN)
%   Replaces the values of the named metadata fields with new values.
% ----------
%   Inputs:
%       fieldN (string scalar): The name of a field in the metadata
%           attributes structure.
%       valueN: The new value to use for the field.
% 
% <a href="matlab:dash.doc('gridfile.editAttributes')">Documentation Page</a>

obj.update;
obj.meta = obj.meta.editAttributes(varargin{:});
obj.save;

end
