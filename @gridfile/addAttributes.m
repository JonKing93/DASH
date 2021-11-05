function[] = addAttributes(obj, varargin)
%% gridfile.addAttributes  Add attributes to gridfile metadata
% ----------
%   <strong>obj.addAttributes</strong>(field1, value1, field2, value2, .., fieldN, valueN)
%   Adds the named fields and associated values to the metadata attributes
%   of the current gridfile.
% ----------
%   Inputs:
%       fieldN (string scalar): The name of a new field for the attributes
%           structure. Must be a valid Matlab variable name and cannot
%           duplicate any fields already in the attributes.
%       valueN: The value associated with the new attributes fields.
%
% <a href="matlab:dash.doc('gridfile.addAttributes')">Documentation Page</a>

obj.meta = obj.meta.addAttributes(varargin{:});

end
