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
%    convert the metadata.
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

% Check dimension, get index. Only allow a single dimension.
d = obj.checkDimensions(dim);
if numel(d)>1
    error('dim can only list a one dimension.');
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

