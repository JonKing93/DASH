function[] = editAttributes(obj, varargin)
%% gridfile.editAttributes  Change existing metadata attributes
% ----------
%   <strong>obj.editAttributes</strong>(fields, values)
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
%       valueN (any data type): The new value to use for the field.
% 
% <a href="matlab:dash.doc('gridfile.editAttributes')">Documentation Page</a>

% Setup
header = "DASH:gridfile:editAttributes";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

% Update attributes
try
    obj.meta = obj.meta.editAttributes(varargin{:});
catch ME
    throw(ME);
end
obj.save;

end
