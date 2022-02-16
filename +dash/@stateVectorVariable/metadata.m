function[obj] = metadata(obj, dims, type, arg1, arg2, header)
%% dash.stateVectorVariable.metadata  Sets metadata options for dimensions of a state vector variable
% ----------
%   obj = <strong>obj.metadata</strong>(dims, 0, [], [], header)
%   Use raw gridfile metadata for the indicated dimensions.
%
%   obj = <strong>obj.metadata</strong>(dims, 1, metadata, [], header)
%   Use user-provided metadata for the indicated dimensions.
%
%   obj = <strong>obj.metadata</strong>(dims, 2, conversionFunctions, conversionArgs, header)
%   Convert metadata for the indicated dimensions using the specified
%   functions and inputs.
% ----------
%   Inputs:
%       dims (vector, linear indices [nDimensions]): The dimensions that
%           should have their metadata options updated.
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

    % Initialize metadata parameters
    metadata = [];
    convertFunction = [];
    convertArgs = [];

    % Parse alternate metadata. 
    if type==1
        metadata = arg1{k};

        % Require rows match the number of state/reference indices
        nIndices = numel(obj.indices{d});
        if nIndices == 0
            nIndices = obj.gridSize(d);
        end
        nRows = size(metadata,1);
        if nRows ~= nIndices
            metadataSizeConflictError(obj, d, nRows, nIndices, header);
        end
    
    % Parse conversion function
    elseif type==2
        convertFunction = arg1{k};
        convertArgs = arg2{k};
        if ~isrow(convertArgs)
            convertArgs = convertArgs';
        end
    end
    
    % Update properties
    obj.metadataType(d) = type;
    obj.metadata_{d} = metadata;
    obj.convertFunction{d} = convertFunction;
    obj.convertArgs{d} = convertArgs;
end

end

% Error message
function[ME] = metadataSizeConflictError(obj, d, nRows, nIndex, header)
dim = obj.dims(d);
if obj.isState(d)
    type = 'state';
else
    type = 'reference';
end
id = sprintf('%s:metadataSizeConflict', header);
ME = MException(id, ...
    ['The alternate metadata for the "%s" dimension must have one row per\n',...
    '%s index (%.f), but it has %.f rows instead.'],...
    dim, type, nIndex, nRows);
throwAsCaller(ME);
end