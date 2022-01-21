function[obj] = metadata(obj, d, type, arg1, arg2, header)

% Only allow ensemble dimensions
if any(obj.isState(d))
    stateDimensionError(obj, d, header);
end

% Initialize properties
metadata = {[]};
convertFunction = {[]};
convertArgs = {[]};

% Parse args for settings
if type==1
    metadata = arg1;
    checkMetadataRows(d, metadata, header);
elseif type==2
    convertFunction = arg1;
    convertArgs = arg2;
end

% Update properties
obj.metadataType(d) = type;
obj.metadata_(d) = metadata;
obj.convertFunction(d) = convertFunction;
obj.convertArgs(d) = convertArgs;

end

% Utilities
function[] = checkMetadataRows(dims, metadata, header)

% Cycle through dimensions
for k = 1:numel(dims)
    d = dims(k);

    % Check that metadata rows match the number of reference indices
    nRows = size(metadata{k}, 1);
    if nRows ~= obj.ensSize(d)
        metadataSizeConflictError(d, nRows, obj.ensSize(d), header);
    end
end

end

% Error message
function[ME] = metadataSizeConflictError(d, nRows, nIndex, header)
dim = obj.dims(d);
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ...
    ['The alternate metadata for the "%s" dimension must have one row per\n',...
    'reference index (%.f), but it has %.f rows instead.'],...
    dim, nIndex, nRows);
throwAsCaller(ME);
end