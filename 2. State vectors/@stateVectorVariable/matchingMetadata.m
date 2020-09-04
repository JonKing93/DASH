function[meta] = matchingMetadata(obj, meta, grid, dim)
%% Return metadata that matches a second set of metadata at the indices
% along a dimension.
%
% meta = obj.matchingMetadata(meta, grid, dim)
%
% ----- Inputs -----
%
% meta: The second set of metadata
%
% grid: The gridfile object associated with the variable.
%
% dim: The name of the dimension. A string
%
% ----- Outputs -----
%
% meta: The metadata intersect

% Get the variable's metadata
[varMeta, d] = obj.dimMetadata(grid, dim);

% Optionally rewrite metadata
if obj.hasMetadata(d)
    varMeta = obj.metadata{d};

% Setup for converting metadata
elseif obj.convert(d)
    nRows = size(varMeta, 1);
    funcInfo = functions(obj.convertFunction{d});
    funcName = funcInfo.function;
    
    % Run the conversion function
    try
        varMeta = obj.convertFunction{d}(varMeta, obj.convertArgs{d}{:});
    catch ME
        failedConversionError(obj.name, dim, funcName, 1, ME);
    end
    
    % Check that converted metadata is still valid. Convert cellstring to
    % string.
    try
        gridfile.checkMetadataField(varMeta);
    catch ME
        failedConversionError(obj.name, dim, funcName, 2, ME);
    end
    if size(varMeta, 1) ~= nRows
        failedConvertsionError(obj.name, dim, funcName, 3, ME, size(varMeta,1), nRows);
    end
    if iscellstr(varMeta) %#ok<ISCLSTR>
        varMeta = string(varMeta);
    end
end

% Get the metadata intersect
try
    meta = intersect(meta, varMeta, 'rows', 'stable');
catch
    meta = [];
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
        'See "gridfile.defineMetadata" for the allowed metadata types.'];
elseif type == 3
    reason = sprintf(['because the number of rows in the converted metadata ',...
        '(%.f) does not match the number of rows in the original metadata (%.f).'], ...
        newRows, oldRows);
end
message = sprintf('%s %s', head, reason);cause = MException('DASH:stateVector:failedMetadataConversion', message);
ME = addCause(ME, cause);
rethrow(ME);
end