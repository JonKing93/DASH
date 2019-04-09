function[] = checkIndices(var, d, index)
%% Low level error checking for indices for a dimension.
%
% var: varDesign
%
% d: Dimension index
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the size of the data
dimSize = var.dimSize(d);

% Indices cannot be empty
if isempty( index )
    error('The indices for the %s dimension of variable %s are empty.', var.dimID(d), var.name);
    
% Must be numeric vectors
elseif ~isnumeric(index) || ~isvector(index)
    error('The indices for the %s dimension of variable %s are not numeric vectors.', var.dimID(d), var.name);
    
% Must be positive integers
elseif any(index<=0) || any( mod(index,1)~=0 )
    error('The indices for the %s dimension of variable %s are not positive integers.', var.dimID(d), var.name);
    
% Cannot be larger than the dimension
elseif any( index>dimSize )
    error('Some indices for the %s dimension in variable %s are larger than the dimension size.', var.dimID(d), var.name);
end

end