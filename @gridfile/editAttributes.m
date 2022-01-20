function[] = editAttributes(obj, varargin)
%% gridfile.editAttributes  Change existing metadata attributes
% ----------
%   obj = <strong>obj.editAttributes</strong>(fields, values)
%   Replaces the values of the named metadata attributes fields with new values.
%
%   <strong>obj.editAttributes</strong>(field1, value1, field2, value2, .., fieldN, valueN)
%   Uses a Name,Value syntax to edit attribute fields.
% ----------
%   Inputs:
%       fields (string vector [nFields]): A list of fields to edit to the
%           attributes structure.
%       values (cell vector [nFields]): The new values associated with each
%           edited attributes field.
%       fieldN (string scalar): The name of a field in the metadata
%           attributes structure.
%       valueN: The new value to use for the field.
% 
% <a href="matlab:dash.doc('gridfile.editAttributes')">Documentation Page</a>

dash.assert.scalarObj(obj, 'DASH:gridfile:editAttributes');
obj.update;
obj.meta = obj.meta.editAttributes(varargin{:});
obj.save;

end
