function[meta] = dimMetadata(obj, grid, dim)
%% Gets the metadata along a dimension at the variable's indices along the
% dimension.
%
% meta = obj.dimMetadata(grid, dim)
%
% ----- Inputs -----
%
% grid: The gridfile object associated with the variable
%
% dim: The name of the dimension. A string
%
% ----- Outputs -----
%
% meta: The metadata along the dimension

% Load any metadata provided directly
d = obj.checkDimensions(dim);
if obj.hasMetadata(d)
    meta = obj.metadata{d};
    
% Otherwise, determine from indices and gridfile metadata
else
    meta = grid.meta.(dim)(obj.indices{d}, :);
    
    % Setup if converting metadata
    if obj.convert(d)
        nRows = size(meta, 1);
        funcInfo = functions(obj.convertFunction{d});
        funcName = funcInfo.function;

        % Run the conversion function
        try
            meta = obj.convertFunction{d}(meta, obj.convertArgs{d}{:});
        catch ME
            failedConversionError(obj.name, dim, funcName, 1, ME);
        end

        % Check that converted metadata is still valid. Convert cellstring to
        % string.
        try
            meta = dash.checkMetadataField(meta, dim);
        catch ME
            failedConversionError(obj.name, dim, funcName, 2, ME);
        end
        if size(meta, 1) ~= nRows
            failedConversionError(obj.name, dim, funcName, 3, ME, size(meta,1), nRows);
        end
    end
end

end

% Error messages
function[] = failedConversionError(var, dim, func, type, ME, newRows, oldRows)
head = sprintf(['Could not convert metadata for the "%s" dimension of ',...
    'variable "%s" using the "%s" function'], dim, var, func);
if type == 1
    reason = sprintf(['because "%s" threw an error when given the "%s" metadata ', ...
        '(and any additional specified arguments) as input.'], func, dim);
elseif type == 2
    reason = ['because the converted metadata was not valid gridfile metadata. ', ...
        'Converted metadata must be a numeric, logical, char, string, cellstring, or ',...
        'datetime matrix. Each row must be unique and cannot contain NaN or NaT elements.'];
elseif type == 3
    reason = sprintf(['because the number of rows in the converted metadata ',...
        '(%.f) does not match the number of rows in the original metadata (%.f).'], ...
        newRows, oldRows);
end
message = sprintf('%s %s', head, reason);
cause = MException('DASH:stateVector:failedMetadataConversion', message);
ME = addCause(ME, cause);
rethrow(ME);
end