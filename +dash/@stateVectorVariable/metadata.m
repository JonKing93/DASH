function[obj] = metadata(obj, d, type, arg1, arg2, header)
%% dash.stateVectorVariable.metadata  Sets metadata options for ensemble dimensions of a state vector variable
% ----------
%   obj = <strong>obj.metadata</strong>(d, 0, [], [], header)
%   Use raw metadata for the indicated dimensions.
%
%   obj = <strong>obj.metadata</strong>(d, 1, metadata, [], header)
%   Use user-provided metadata for the indicated dimensions.
%
%   obj = <strong>obj.metadata</strong>(d, 2, conversionFunctions, conversionArgs, header)
%   Convert metadata for the indicated dimensions using the specified
%   functions and inputs.
% ----------
%   Inputs:
%       d (vector, linear indices [nDimensions]): The ensemble dimensions
%           that should be updated.
%       metadata (cell vector [nDimensions] {metadata matrix}): Alternate
%           metadata to use for each dimension.
%       conversionFunctions (cell vector [nDimensions] {function_handle}):
%           Handle to the conversion function to use for each dimension.
%       conversionArgs (cell vector [nDimensions] {cell vector}):
%           Additional input arguments to the conversion function for each dimension.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       obj (scalar dash.stateVectorVariable object): The variable with
%           updated metadata parameters.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.metadata')">Documentation Page</a>

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