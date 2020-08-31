function[obj] = design(obj, varNames, dims, type, indices)
%% Designs a dimension of a stateVectorVariable
%
% obj = obj.design(varNames, dim, type)
% obj = obj.design(varNames, dim, isState)
% Specifies a dimension as a state dimension or ensemble dimension. Uses
% all elements along the dimension as state indices or ensemble reference
% indices, as appropriate.
%
% obj = obj.design(varNames, dim, 's'/'state', stateIndices)
% Specify state indices for a dimension.
%
% obj = obj.design(varNames, dim, 'e'/'ens'/'ensemble', ensIndices)
% Specify ensemble indices for a dimension.
%
% obj = obj.design(varNames, dims, isState/type, indexCell)
% Specify dimension type and indices for multiple dimensions.
%
% ----- Inputs -----
%
% dim: The name of one of the variable's dimensions. A string.
%
% dims: The names of multiple dimensions. A string vector or cellstring
%    vector. May not repeat dimension names.
%
% type: Options are ("state" or "s") to indicate a state dimension, and
%    ("ensemble" / "ens" / "e") to indicate an ensemble dimension. Use a
%    string scalar to specify the same type for all dimensions listed in
%    dims. Use a string vector to specify different options for the
%    different dimensions listed in dims.
%
% isState: True indicates that a dimension is a state dimension. False
%    indicates an ensemble dimension. Use a scalar logical to use the same
%    type for all dimensions listed in dims. Use a logical vector to
%    specify different options for the different dimensions listed in dims.
%
% stateIndices: The indices of required data along the dimension in the
%    variable's .grid file. Either a vector of linear indices or a logical
%    vector the length of the dimension.
%
% ensIndices: The ensemble reference indices. Either a vector of linear
%    indices or a logical vector the length of the dimension.
%
% indexCell: A cell vector. Each element contains the state indices or
%    ensemble reference indices for a dimension listed in dims, as
%    appropriate. Must be in the same order as dims. If an element is an
%    empty array, uses all indices along the dimension.

% Default for indices
if ~exist('indices','var')
    indices = [];
end

% Error check, variable index
v = obj.checkVariables(varNames);

% Update each variable
for k = 1:numel(v)
    obj.variables(v) = obj.variables(v).design(dims, type, indices);
    
    % Find any secondary coupled variables not specified by the user
    cv = find(obj.coupled(v(k),:));
    sv = cv(~ismember(cv, v));
    
    % Update these variables. Notify user. Add to variables list.
    notifySecondaryVariables(sv);
    
    
    

% Update the dimensions of coupled variables
% obj.updateCoupledVariables(v);

end