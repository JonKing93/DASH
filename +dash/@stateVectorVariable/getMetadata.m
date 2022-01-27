function[metadata, failed, cause] = getMetadata(obj, d, grid, header)
%% Returns the metadata for a dimension of a state vector variable
%
%
%   Throws:
%       couldNotBuildGridfile
%       invalidGridfile
%       conversionFunctionFailed
%       invalidConversion
%       metadataSizeConflict
%       

% Initialize output for error handling
metadata = [];
failed = false;
cause = [];

% Use alternate metadata directly
if obj.metadataType(d) == 1
    metadata = obj.metadata{d};
    return
end

% Build gridfile object if necessary
if dash.is.strflag(grid)
    try
        grid = gridfile(grid);
    catch ME
        [failed, cause] = labelError(ME, 'couldNotBuildGridfile', header);
        return
    end

    % Validate the gridfile object
    [isvalid, cause] = obj.validateGrid(grid, header);
    if ~isvalid
        [failed, cause] = labelError(cause, 'invalidGridfile', header);
        return
    end
end

% Extract metadata from gridfile
dim = obj.dims(d);
metadata = grid.metadata.(dim)(obj.indices{d}, :);

% Finished if using raw metadata
if obj.metadataType(d) == 0
    return
end

% Run the conversion function
try
    metadata = obj.convertFunction{d}(metadata, obj.convertArgs{d}{:});
catch ME
    [failed, cause] = labelError(ME, 'conversionFunctionFailed', header);
    return
end

% Check that converted metadata is a valid metadata matrix
try
    metadata = gridMetadata(dim, metadata);
    metadata.assertUnique(dim, header);
    metadata = metadata.(dim);
catch ME
    [failed, cause] = labelError(ME, 'invalidConversion', header);
    return
end

% Check the number of rows match the ensemble size
nRows = size(metadata, 1);
if nRows ~= obj.ensSize(d)
    ME = metadataSizeConflict(obj, d, nRows, header);
    [failed, cause] = labelError(ME, 'metadataSizeConflict', header);
end

end

% Error messages
function[failed, ME] = labelError(cause, label, header)
failed = true;
id = sprintf('%s:%s', header, label);
ME = MException(id, '');
ME = addCause(ME, cause);
end
function[ME] = metadataSizeConflict(obj, d, nRows, header)
dim = obj.dims(d);
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ['The "%s" metadata must have %.f rows, but the output from ',...
    'the metadata conversion function has %.f rows instead.'], ...
    dim, obj.ensSize(d), nRows);
end