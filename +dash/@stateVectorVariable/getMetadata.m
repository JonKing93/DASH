function[metadata, failed, cause] = getMetadata(obj, d, grid, header)
%% dash.stateVectorVariable.getMetadata  Return metadata along a dimension of a state vector variable
% ----------
%   [metadata, failed, cause] = <strong>obj.getMetadata</strong>(d, grid, header)
%   Returns final metadata along the indexed dimension. Selects metadata
%   from a gridfile, user-specified alternate metadata, or from the output
%   of a conversion function, as appropriate.
%
%   In some cases, the method can fail to return the metadata. This can
%   occur if a gridfile fails to build, or if a metadata conversion
%   function fails. In this case, the method notes the failure and returns
%   the cause of the failure.
% ----------
%   Inputs:
%       d (scalar linear index): The index of a dimension in the variable
%       grid (string scalar | scalar gridfile object): The gridfile
%           object required to load the metadata. If grid is
%           a string scalar, attempts to build the gridfile when gridfile
%           metadata is required. If grid is a gridfile object, extracts
%           metadata directly from the object without validating.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       metadata ([] | metadata matrix): Metadata for the dimension. If the
%           method failed to obtain the metadata, returns an empty array.
%       failed (scalar logical): True if the method failed to return the
%           metadata. Otherwise false
%       cause ([] | scalar MException): The cause of the metadata failure.
%           If the metadata was returned successfully, an empty array.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.getMetadata')">Documentation Page</a>

% Initialize output for error handling
failed = false;
cause = [];

% Return alternate metadata directly
if obj.metadataType(d)==1
    metadata = obj.metadata_{d};
    return
end

% Otherwise, build gridfile if necessary
if dash.is.strflag(grid)
    try
        grid = gridfile(grid);
    catch ME
        [metadata, failed, cause] = labelError(ME, 'couldNotBuildGridfile', header);
        return
    end

    % Validate the gridfile object
    [isvalid, cause] = obj.validateGrid(grid, header);
    if ~isvalid
        [metadata, failed, cause] = labelError(cause, 'invalidGridfile', header);
        return
    end
end

% Extract full gridfile metadata for the dimension
dimension = obj.dims(d);
metadata = grid.meta.(dimension);

% Use metadata at state / reference indices.
rows = obj.indices{d};
if isempty(rows)
    rows = 1:obj.gridSize(d);
end
metadata = metadata(rows,:);

% Exit if not applying conversion function
if obj.metadataType(d)~=2
    return
end

% Run the conversion function
try
    metadata = obj.convertFunction{d}(metadata, obj.convertArgs{d}{:});
catch ME
    [metadata, failed, cause] = labelError(ME, 'conversionFunctionFailed', header);
    return
end

% Check that converted metadata is a valid metadata matrix
try
    metadata = gridMetadata(dimension, metadata);
    metadata.assertUnique(dimension, header);
    metadata = metadata.(dimension);
catch ME
    [metadata, failed, cause] = labelError(ME, 'invalidConversion', header);
    return
end

% Check the number of rows is correct
nRows = size(metadata, 1);
nRequired = numel(rows);
if nRows ~= nRequired
    ME = metadataSizeConflict(obj, d, nRows, nRequired, header);
    [metadata, failed, cause] = labelError(ME, 'metadataSizeConflict', header);
end

end

% Error messages
function[metadata, failed, ME] = labelError(cause, label, header)
metadata = [];
failed = true;
id = sprintf('%s:%s', header, label);
ME = MException(id, '');
ME = addCause(ME, cause);
end
function[ME] = metadataSizeConflict(obj, d, nRows, nRequired, header)
dim = obj.dims(d);
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ['The "%s" metadata must have %.f rows, but the output from ',...
    'the metadata conversion function has %.f rows instead.'], ...
    dim, nRequired, nRows);
end