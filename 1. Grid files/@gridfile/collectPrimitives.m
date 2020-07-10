function[varargout] = collectPrimitives(obj, fieldNames, sources)
%% Collects source primitive arrays in a cell.
%
% X = obj.collectPrimitives( fieldName )
% Collects the values of a primitive array in a cell column vector. Removes
% padded values from each cell. Converts char fields to string.
%
% [X, Y, ..., Z] = obj.collectPrimitives( fieldNames )
% Collects multiple fields.
%
% [...] = obj.collectPrimitives( fieldNames, sources )
% Only collect values for specified sources.
%
% ----- Inputs -----
%
% fieldName: The name of a field, a string.
%
% fieldNames: String vector.
%
% sources: Linear source indices.
%
% ----- Outputs -----
%
% X, Y, Z: The cell or string arrays extracted from the primitive array.

% Default if sources is unset
if ~exist('sources','var') || isempty(sources)
    sources = 1:size(obj.fieldLength,1);
end

% Determine which field to convert
sourceFields = fields(obj.source);
[~, f] = ismember(fieldNames, sourceFields);

% Preallocate the cell output
nVars = numel(fieldNames);
nSource = numel(sources);
varargout = repmat({cell(nSource,1)}, [1 nVars]);

% Collect primitives
for v = 1:nVars
    name = fieldNames(v);
    for s = 1:nSource
        row = sources(s);
        varargout{v}{s} = obj.source.(name)(row, 1:obj.fieldLength(row,f(v)));
    end
    
    % Convert chars to string
    if iscellstr(varargout{v})
        varargout{v} = string(varargout{v});
    end
end

end 