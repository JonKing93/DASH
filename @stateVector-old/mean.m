function[obj] = mean(obj, varNames, dims, indices, omitnan)
%% Specifies options for taking a mean over dimensions for specified variables.
%
% obj = obj.mean(varNames, stateDim)
% obj = obj.mean(varNames, stateDim, []);
% Take a mean over a state dimension.
%
% obj = obj.mean(varNames, ensDim, indices);
% Specify how to take a mean over an ensemble dimension.
%
% obj = obj.mean(varNames, dims, indexCell)
% Specify how to take a mean over multiple dimensions.
%
% obj = obj.mean(varNames, dims, indices, nanflag)
% obj = obj.mean(varNames, dims, indices, omitnan)
% Specify how to treat NaN values when taking a mean
%
% ----- Inputs -----
%
% varNames: The names of the variables over which to take a mean. A string
%    vector or cellstring vector.
%
% stateDim: The name of a state dimension for the variable. A string.
%
% ensDim: The name of an ensemble dimension for the variable. A string.
%
% dims: The names of multiple dimensions. A string vector or cellstring
%    vector. May not repeat dimension names.
%
% indices: Mean indices for an ensemble dimension. A vector of integers
%    that indicates the position of mean data-elements relative to the
%    sequence data-elements. 0 indicates a sequence data-element. 1 is the
%    data-element following a sequence data-element. -1 is the data-element
%    before a sequence data-element, etc. Mean indices may be in any order 
%    and cannot have a magnitude larger than the length of the dimension in
%    the .grid file.
%
% indexCell: A cell vector. Each element contains mean indices for one
%    dimension listed in dims. Must be in the same order as dims. Use an
%    empty array for elements corresponding to state dimensions.
%
% nanflag: Options are "includenan" to use NaN values (default) and
%    "omitnan" to remove NaN values. Use a string scalar to specify an
%    option for all dimensions listed in dims. Use a string vector to
%    specify different options for the different dimensions listed in dims.
%
% omitnan: If false (default) includes NaN values in a mean. If true,
%    removes NaN values. Use a scalar logical to use the same option for
%    all dimensions listed in dims. Use a logical vector to specify
%    different options for the different dimensions listed in dims.
%
% ----- Outputs -----
%
% obj: The updated stateVector object.

% Defaults for unset variables
if ~exist('dims','var')
    dims = [];
end
if ~exist('indices','var')
    indices = [];
end
if ~exist('omitnan','var')
    omitnan = [];
end

% Error check. Variable indices, editable
obj.assertEditable;
v = obj.checkVariables(varNames);

% Update variables
for k = 1:numel(v)
    obj.variables(v(k)) = obj.variables(v(k)).mean(dims, indices, omitnan);
end

end