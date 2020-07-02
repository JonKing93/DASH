function[varargout] = collectPrimitives(obj, fieldNames)
%% Collects source primitive arrays in a cell.
%
% X = obj.collectPrimitives( fieldName )
% Collects the values of a primitive array in a cell column vector. Removes
% padded values from each cell. Converts char fields to string.
%
% [X, Y, ..., Z] = obj.collectPrimitives( fieldNames )
% Collects multiple fields.
%
% ----- Inputs -----
%
% fieldName: The name of a field, a string.
%
% fieldNames: String vector.
%
% ----- Outputs -----
%
% X: The cell or string array extract from the primitive array.

% Determine which field to convert
sourceFields = fields(obj.source);
[~, f] = ismember(fieldNames, sourceFields);

% Preallocate the cell output
nVars = numel(fieldNames);
nSource = size(obj.fieldLength, 1);
varargout = repmat({cell(nSource,1)}, [1 nVars]);

% Collect primitives
for v = 1:nVars
    name = fieldNames(v);
    for s = 1:nSource
        varargout{v}{s} = obj.source.(name)(s, 1:obj.fieldLength(s,f(v)));
    end
    
    % Convert chars to string
    if iscellstr(varargout{v})
        varargout{v} = string(varargout{v});
    end
end

end 