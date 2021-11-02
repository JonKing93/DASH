function[obj] = addAttributes(obj, varargin)
%% gridMetadata.addAttributes  Add non-dimensional attributes to the metadata for a gridded dataset
% ----------
%   obj = obj.addAttributes(field1, value1, field2, value2, .., fieldN, valueN)
%   Adds the named fields and associated values to the attributes structure
%   of a gridMetadata object.
% ----------
%   Inputs:
%       fieldN (string scalar): The name of a new field for the attributes
%           structure. Must be a valid Matlab variable name and cannot
%           duplicate any fields already in the attributes.
%       valueN: The value associated with the new attributes field.
%
%   Outputs:
%      obj (gridMetadata object): The updated gridMetadata object
%
% <a href="matlab:dash.doc('gridMetadata.addAttributes')">Documentation Page</a>

% Header for error IDs
header = "DASH:gridMetadata:addAttributes";

% Require an even number of inputs
nArgs = numel(varargin);
if mod(nArgs,2)~=0
    id = sprintf('%s:oddNumberOfInputs', header);
    error(id, 'There must be an even number of inputs. (Inputs should be fieldname, value pairs)');
end

% Get the attributes structure and field names
[~, atts] = gridMetadata.dimensions;
attributes = obj.(atts);
fields = string(fieldnames(attributes));

% Get the new field name for each Name,Value paor
for v = 1:2:nArgs-1
    inputName = sprintf('Input %.f', v);
    name = dash.assert.strflag(varargin{v}, inputName, header);
    
    % Require valid Matlab variable name
    if ~isvarname(name)
        id = sprintf('%s:invalidFieldName', header);
        error(id, ['"%s" cannot be used as an attributes field ',...
        'because it is not a valid Matlab variable name.'], name)
    
    % Prevent duplicate fields
    elseif ismember(name, fields)
        id = sprintf('%s:duplicateFieldName', header);
        error(id, '"%s" is already a field in the attributes', name);
    end
    
    % Add to the structure
    attributes.(name) = varargin{v+1};
    fields = cat(1, fields, name);
end
obj.(atts) = attributes;

end
    
    