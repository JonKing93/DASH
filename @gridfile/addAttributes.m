function[] = addAttributes(obj, varargin)
%% gridfile.addAttributes  Add attributes to gridfile metadata
% ----------
%   <strong>obj.addAttributes</strong>(fields, values)
%   Adds the named fields and associated values to the metadata attributes
%   of the current gridfile.
%
%   <strong>obj.addAttributes</strong>(field1, value1, field2, value2, .., fieldN, valueN)
%   Uses a Name,Value syntax to add attributes.
% ----------
%   Inputs:
%       fields (string vector [nFields]): A list of fields to add to the
%           attributes structure.
%       values (cell vector [nFields]): The values associated with each
%           new attributes field.
%       fieldN (string scalar): The name of a new field for the attributes
%           structure. Must be a valid Matlab variable name and cannot
%           duplicate any fields already in the attributes.
%       valueN: The value associated with the new attributes fields.
%
% <a href="matlab:dash.doc('gridfile.addAttributes')">Documentation Page</a>

dash.assert.scalarObj(obj, 'DASH:gridfile:addAttributes');
obj.update
obj.meta = obj.meta.addAttributes(varargin{:});
obj.save;

end
