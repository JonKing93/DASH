function[obj] = convertMetadata(obj, dim, convertFunction, functionArgs)
%% Specify how to convert the metadata along a dimension of variables in a
% state vector.
%
% obj = obj.convertMetadata(dim, convertFunction)
% Specifies a function to use to convert metadata along a particular
% dimension.
%
% obj = obj.convertMetadata(dim, convertFunction, functionArgs)
% Specify additional input arguments for the metadata conversion function.
% 
% ***Note: Metadata will be converted via
%   >> convertedMetadata = convertFunction( metadata, functionArgs{:} )
% so functionArgs should list input arguments 2-N.
%
% ----- Inputs -----
%
% dim: The name of the dimension in the variables over which to apply the
%    metadata conversion. A string scalar or character row vector.
%
% convertFunction: The function handle for the function being used to
%    convert the metadata. The conversion function should convert metadata
%    to a numeric, logical, char, string, cellstring, or datetime matrix.
%    It must preserve the number of rows in the original metadata. Each row
%    of the converted metadata will be used as the metadata for one element
%    along the dimension. Converted metadata cannot contain NaN, Inf, or
%    NaT elements. 
%
% functionArgs: A cell vector containing additional arguments that should
%    be passed to the conversion function. Elements should be in the same
%    order in which they should be passed to the conversion function. Note
%    that the first input to the conversion function will be the metadata,
%    so the first element of functionArgs will be the second input argument
%    to the conversion function.
%
% ----- Outputs -----
%
% obj: The updated stateVector object.

% Error check, dimension index. Cannot conflict with previous metadata
d = obj.checkDimensions(dim, false);
if any(obj.hasMetadata(d))
    previousMetadataError(obj, d);
end

% Error check function. Default and error check args.
if ~isa(convertFunction, 'function_handle') || ~isscalar(convertFunction)
    error('convertFunction must be a scalar function handle.');
end
if ~exist('functionArgs','var') || isempty(functionArgs)
    functionArgs = {};
end
dash.assertVectorTypeN(functionArgs, 'cell', [], 'functionArgs');

% Update
obj.convert(d) = true;
obj.convertFunction{d} = convertFunction;
obj.convertArgs{d} = functionArgs;

end

% Error message
function[] = previousMetadataError(obj, d)
bad = d(find(obj.convert(d),1));
error('Cannot specify a metadata conversion function for the "%s" dimension ',...
    'of variable "%s" because you previously specified metadata for the ',...
    'reference indices of this dimension. You may want to reset the metadata ',...
    'options using "stateVector.resetMetadata".', obj.dims(bad), obj.name);
end