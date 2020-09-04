function[obj] = convertMetadata(obj, varNames, dim, convertFunction, functionArgs)
%% Specify how to convert the metadata along a dimension of variables in a
% state vector.
%
% obj = obj.convertMetadata(varNames, dim, convertFunction)
% Specifies a function to use to convert metadata along a particular
% dimension for specified variables.
%
% obj = obj.convertMetadata(varNames, dim, convertFunction, functionArgs)
% Specify additional input arguments for the metadata conversion function.
% 
% ***Note: Metadata will be converted via
%   >> convertedMetadata = convertFunction( metadata, functionArgs{:} )
% so functionArgs should list input arguments 2-N.
%
% ----- Inputs -----
%
% varNames: The names of variables in the state vector that should have
%    their metadata converted. A string vector or cellstring vector.
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

% Default for functionArgs
if ~exist('functionArgs','var')
    functionArgs = [];
end

% Error check variables, get indices
v = obj.checkVariables(varNames);

% Update each variable
for k = 1:numel(v)
    obj.variables(v(k)) = obj.variables(v(k)).convertMetadata(dim, convertFunction, functionArgs);
end

end