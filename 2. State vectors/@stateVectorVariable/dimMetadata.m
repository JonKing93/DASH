function[meta] = dimMetadata(obj, grid, dim)
%% Gets the metadata along a dimension at the variable's indices along the
% dimension.
%
% meta = obj.dimMetadata(grid, dim)
%
% ----- Inputs -----
%
% grid: The gridfile object associated with the variable
%
% dim: The name of the dimension. A string
%
% ----- Outputs -----
%
% meta: The metadata along the dimension

d = obj.checkDimensions(dim);
meta = grid.meta.(dim)(obj.indices{d}, :);

end