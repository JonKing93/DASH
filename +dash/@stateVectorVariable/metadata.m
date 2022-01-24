function[obj] = metadata(obj, dims, type, arg1, arg2, header)
%% dash.stateVectorVariable.metadata  Sets metadata options for ensemble dimensions of a state vector variable
% ----------
%   obj = <strong>obj.metadata</strong>(dims, 0, [], [], header)
%   Use raw metadata for the indicated dimensions.
%
%   obj = <strong>obj.metadata</strong>(dims, 1, metadata, [], header)
%   Use user-provided metadata for the indicated dimensions.
%
%   obj = <strong>obj.metadata</strong>(dims, 2, conversionFunctions, conversionArgs, header)
%   Convert metadata for the indicated dimensions using the specified
%   functions and inputs.
% ----------
%   Inputs:
%       dims (vector, linear indices [nDimensions]): The ensemble dimensions
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

% Cycle through dimensions, skip missing dimensions
for k = 1:numel(dims)
    d = dims(k);
    if d==0
        continue;
    end

    % Only allow ensemble dimensions
    if obj.isState(d)
        stateDimensionError(obj, d, header);
    end

    % Initialize metadata parameters
    metadata = [];
    convertFunction = [];
    convertArgs = [];

    % Parse metadata. Require rows match the number of reference indices
    if type==1
        metadata = arg1{k};
        nRows = size(metadata,1);
        if nRows ~= obj.ensSize(d)
            metadataSizeConflictError(d, nRows, obj.ensSize(d), header);
        end
    
    % Parse conversion function
    elseif type==2
        convertFunction = arg1{k};
        convertArgs = arg2{k};
    end
    
    % Update properties
    obj.metadataType(d) = type;
    obj.metadata_(d) = metadata;
    obj.convertFunction(d) = convertFunction;
    obj.convertArgs(d) = convertArgs;
end

end

% Error message
function[] = stateDimensionError(obj, d, header)

dim = obj.dims(d);
link = '<a href="matlab:dash.doc(''stateVector.design'')">stateVector.design</a>';

id = sprintf('%s:metadataOfStateDimension', header);
ME = MException(id, ...
    ['Cannot edit metadata settings for the "%s" dimension because "%s" is not an\n',...
    'ensemble dimension. Either remove "%s" from the list of dimensions with metadata\n',...
    'settings, or convert it to an ensemble dimension using %s.'],...
    dim, dim, dim, link);
throwAsCaller(ME);
end
function[ME] = metadataSizeConflictError(d, nRows, nIndex, header)
dim = obj.dims(d);
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ...
    ['The alternate metadata for the "%s" dimension must have one row per\n',...
    'reference index (%.f), but it has %.f rows instead.'],...
    dim, nIndex, nRows);
throwAsCaller(ME);
end