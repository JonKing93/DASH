function[obj] = metadata(obj, variables, dimensions, metadataType, varargin)
%% stateVector.metadata  Specify how to process metadata along dimensions of state vector variables
% ----------
%   obj = <strong>obj.metadata</strong>(-1, ...)
%   obj = <strong>obj.metadata</strong>(v, ...)
%   obj = <strong>obj.metadata</strong>(variableNames, ...)
%   Specifies how to process metadata for the listed variables. If the
%   first input is -1, applies the settings to all variables currently in
%   the state vector.
%
%   obj = <strong>obj.metadata</strong>(variables, dimensions, metadataType, ...)
%   Specify how to process metadata for the indicated dimensions of the
%   listed variables. This metadata is used when building ensemble members
%   of a state vector ensemble. The metadata is used to ensure that coupled
%   variables within an ensemble member all correspond to the same point. 
%   This check proceeds by searching for matching metadata along the
%   ensemble dimensions of coupled variables, and pinning the variables at
%   matching metadata points. In the default case, this metadata is
%   extracted from the gridfile metadata for each ensemble dimension.
%
%   However, different variables can use different metadata formats within
%   their gridfiles, which can prevent the metadata check from finding
%   matching metadata. This method allows you to specify alternate metadata, 
%   or a metadata conversion method, to facilitate the comparison of
%   metadata in different formats.
%
%   This method is perhaps most commonly used to combine variables on
%   different time steps. If this describes your scenario, check out the
%   HOW-TO page on combining annual and seasonal data, which is located in
%   the documentation.
%
%   obj = <strong>obj.metadata</strong>(variables, dimensions, 0|"r"|"raw")
%   Use raw gridfile metadata for the indicated dimensions of the
%   variables. Metadata for each dimension is extracted from the gridfile
%   metadata for the dimension. This is the default behavior.
%
%   obj = <strong>obj.metadata</strong>(variables, dimensions, 1|"s"|"set", alternateMetadata)
%   Specify an alternate set of metadata to use for a dimension, which will
%   be used instead of the gridfile metadata. The metadata must be a
%   matrix, and the number of rows must match the number of state/reference
%   indices for the dimension.
%
%   obj = <strong>obj.metadata</strong>(variables, dimensions, 2|"c"|"convert", conversionFunction)
%   obj = <strong>obj.metadata</strong>(variables, dimensions, 2|"c"|"convert", conversionFunction, conversionArgs)
%   Specify a function that can be used to convert gridfile metadata to a
%   different format. The function must accept the metadata being converted
%   as its first argument. You may use any built-in or user-defined
%   function, which should be input as a function handle.
%
%   You may optionally provide additional arguments to be passed to the
%   conversion function. These arguments should be organized in a cell
%   vector. These input arguments will be passed to the conversion function
%   in order, after the metadata argument. If you provide N optional
%   arguments, they will be passed to the conversion function as input
%   arguments 2 to N+1, as per the following:
%
%   convertedMetadata = conversionFunction(gridfile metadata, args{1}, args{2}, ... arg{N})
% ----------
%   Inputs:
%       v (logical vector | linear indices | -1): The indices of variables in
%           the state vector that should have metadata updated. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If linear indices, may not contain repeated
%           indices. If -1, selects all variables in the state vector.
%       variableNames (string vector): The names of variables in the state
%           vector that should have metadata updated. May not contain
%           repeated variable names.
%       dimensions (string vector [nDimensions]): The names of the ensemble dimensions
%           that should have their metadata updated. Each dimension must be an
%           ensemble dimension in all listed variables. Cannot have
%           repeated dimension names.
%       metadataType (scalar integer | scalar string): Specifies how the
%           metadata for the dimensions should be processed.
%           [0|"r"|"raw" (default)]: Use gridfile metadata
%           [1|"s"|"set"]: Use an alternate set of user-specified metadata
%           [2|"c"|"convert"]: Apply a conversion function to gridfile metadata
%       alternateMetadata (cell vector [nDimensions]{matadata matrix [nIndices x ?]}):
%           Alternate metadata to use for the dimensions. Each element
%           should hold a metadata matrix, and the number of metadata rows
%           for each matrix should match the length of the corresponding
%           gridfile dimension. Each metadata matrix should have unique
%           rows.
%
%           Metadata matrices may have a numeric, logical, char, string,
%           cellstring, or datetime data type. They cannot contain NaN or
%           NaT elements. Cellstring metadata will be converted to string.
%
%           If only a single dimension is indicated, you may provide the
%           alternate metadata directly, instead of as a scalar cell.
%           However, the scalar cell syntax is also permitted.
%       conversionFunction (cell vector [nDimensions], {scalar function_handle}):
%           The conversion functions to use for each of the indicated
%           dimensions. A cell vector with one element per listed
%           dimension. Each element holds a function handle for the conversion
%           function to use for the dimension. If only a single dimension
%           is listed, you may also provide the function handle directly,
%           instead of in a scalar cell.
%       conversionArgs (cell vector [nDimensions, {cell vector {function args}}):
%           Additional arguments to each conversion function. A cell vector
%           with one element per conversion function handle. Each element
%           holds the additional arguments to the conversion function. If a
%           conversion function has no additional arguments, the corresponding
%           element of conversionArgs should hold an empty cell. If only a
%           single dimension is listed, you may provide the additional
%           arguments for the conversion function directly as a cell
%           vector, instead of within a scalar cell.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated
%           metadata specifications.
%
% <a href="matlab:dash.doc('stateVector.metadata')">Documentation Page</a>

% Setup
header = "DASH:stateVector:metadata";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Error check variables and dimensions. Get indices
v = obj.variableIndices(variables, false, header);
[d, dimensions] = obj.dimensionIndices(v, dimensions, header);

% Parse the metadata type
typeStrings = {["r";"raw"]; ["s";"set"]; ["c";"convert"]};
type = dash.parse.switches(metadataType, typeStrings, 1, ...
    'Metadata type', 'allowed metadata type', header);

% Error check based on type
try
    if type==0
        args = checkRaw(varargin);
    elseif type==1
        args = checkSet(dimensions, varargin, header);
    elseif type==2
        args = checkConvert(dimensions, varargin, header);
    end
catch ME
    throw(ME);
end

% Update the variables
method = 'metadata';
inputs = [{type}, args, {header}];
task = 'update the metadata for';
obj = obj.editVariables(v, d, method, inputs, task);

end

% Utility functions
function[args] = checkRaw(varargs)

% Don't allow additional inputs
if numel(varargs)>0
    dash.error.tooManyInputs;
end

% No args needed
args = {[], []};

end
function[args] = checkSet(dimensions, varargs, header)

% Require single metadata input
if numel(varargs)==0
    dash.error.notEnoughInputs;
elseif numel(varargs)>1
    dash.error.tooManyInputs;
end
metadata = varargs{1};

% Error check metadata
nDims = numel(dimensions);
metadata = dash.parse.inputOrCell(metadata, nDims, 'alternateMetadata', header);
for d = 1:nDims
    meta = gridMetadata(dimensions(d), metadata{d});
    meta.assertUnique(dimensions(d), header);
    metadata{d} = meta.(dimensions(d));
end

% Only arg is metadata
args = {metadata, []};

end
function[args] = checkConvert(dimensions, varargs, header)

% Allow one or two inputs
if numel(varargs)==0
    dash.error.notEnoughInputs;
elseif numel(varargs)>2
    dash.error.tooManyInputs;
end
nDims = numel(dimensions);

% Error check conversion function
convertFunction = varargs{1};
convertFunction = dash.parse.inputOrCell(convertFunction, nDims, 'conversionFunction', header);
for d = 1:nDims
    if ~isa(convertFunction{d}, 'function_handle')
        notFunctionHandleError(dimensions, d, header);
    end
end

% Parse the optional args
if numel(varargs)==1
    convertArgs = repmat({{}}, 1, nDims);
    args = {convertFunction, convertArgs};
    return;
end

% Error check conversion args
convertArgs = varargs{2};
nEls = [];
if nDims > 1
    nEls = nDims;
end
dash.assert.vectorTypeN(convertArgs, 'cell', nEls, 'conversionArgs', header);

% Process convert args for single dimension case
if nDims==1
    content1 = convertArgs{1};
    if ~isscalar(convertArgs) || ~iscell(content1) || ~isvector(content1)
        convertArgs = {convertArgs};
    end
end

% Args are the function handle and input args
args = {convertFunction, convertArgs};

end

% Error messages
function[] = notFunctionHandleError(dimensions, d, header)
nDims = numel(dimensions);
extraInfo = '';
if nDims>1
    extraInfo = sprintf('(Element %.f of conversionFunction). ', d);
end
link = '<a href="matlab:doc function_handle">function handle documentation</a>';

id = sprintf('%s:elementNotFunctionHandle', header);
error(id, ['The conversion function input for the "%s" dimension is not a function ',...
    'handle. %sFor additional help with function handles, check out the %s.'],...
    dimensions(d), extraInfo, link);
end
