function[obj] = mean(obj, varName, dims, weights, nanflag)
%% Specify to take a mean over dimensions of a state vector variable.
%
% obj = obj.mean(varName, dims)
% Takes the mean over the specified dimensions of a variable in a state
% vector.
%
% obj = obj.mean(varName, dims, weightCell)
% obj = obj.mean(varName, dims, weightMatrix)
% Uses a weighted mean.
%
% obj = obj.mean(varName, dims, weights, nanflag)
% obj = obj.mean(varName, dims, weights, omitnan)
% Specify how to treat NaN values along each dimension. By default, NaN
% values are included in means.
%
% ----- Inputs -----
%
% varName: The name of a variable in the state vector.
%
% dims: The names of dimensions over which to take a mean. A string vector 
%    or cellstring vector. Dimensions may be in any order and may not
%    contain duplicate names.
%
% weightCell: A cell vector. Each element contains the weights for one
%    dimension; must follow the same order of dimensions as dims. The
%    weights for each dimension must be a numeric vector the length of the
%    dimension in the state vector and may not contain NaN or Inf elements.
%
% weightMatrix: An N-dimensional numeric matrix containing weights for 
%    taking a mean across specified dimensions. Must have a dimension for 
%    each dimension listed in dims. The dimensions of weightMatri must
%    follow the same order as dims and be the length of the dimension in
%    the stateVector. May not contain NaN or Inf.
%
% nanflag: A string or cellstring. If a scalar, specifies how to treat NaN
%    values for all dimensions when taking a mean. Use "includenan"
%    (the default), to include NaN values in means; use "omitnan" to
%    exclude NaN values. If a vector, elements may be "includenan" or 
%    "omitnan" and indicate how to treat NaNs along a particular dimension.
%    Must have one element per dimension listed in dims and be in the same
%    dimension order as dims.
%
% omitnan: A logical. If a scalar, specifies whether to include NaN values
%    (false -- the default), or exclude NaN values (true) from all
%    dimensions when taking a mean. If a vector, each element indicates how
%    to treat NaNs along a particular dimension. Must have one element per
%    dimension listed in dims and be in the same dimension order as dims.

% 