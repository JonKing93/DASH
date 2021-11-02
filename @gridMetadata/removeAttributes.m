function[obj] = removeAttributes(obj, varargin)
%% gridMetadata.removeAttributes  Remove attributes from the metadata of a gridded dataset
% ----------
%   obj = obj.removeAttributes(fields)
%   obj = obj.removeAttributes(field1, field2, .., fieldN)
%   Removes the listed fields from the metadata attributes of the current
%   gridMetadata object.
% ----------
%   Inputs:
%       fields (string vector): A list of fields to remove from the
%           metadata attributes.
%       fieldN (string scalar): The name of a field to remove from the
%           metadata attributes.
%
%   Outputs:
%       obj (gridMetadata object): The updated gridMetadata object
%
% <a href="matlab:dash.doc('gridMetadata.removeAttributes')">Documentation Page</a>

% Error ID header
header = "DASH:gridMetadata:removeAttributes";

% Get current field names
[~, atts] = gridMetadata.dimensions;
attributes = obj.(atts);
fields = string(fieldnames(attributes));
listName = 'field in the attributes structure';

% Require inputs
if numel(varargin)==0
    error('MATLAB:minrhs', 'Not enough input arguments');

% 1 input syntax
elseif numel(varargin)==1
    remove = dash.assert.strlist(varargin{1});
    dash.assert.strsInList(remove, fields, 'fields', listName, header);
    
% Multiple inputs
else
    nArgs = numel(varargin);
    remove = strings(nArgs, 1);
    for v = 1:nArgs
        inputName = sprintf('Input %.f', v);
        remove(v) = dash.assert.strflag(varargin{v}, inputName, header);
        dash.assert.strsInList(remove(v), fields, inputName, listName, header);
    end
end

% Remove the fields
attributes = rmfield(attributes, remove);
obj.(atts) = attributes;

end