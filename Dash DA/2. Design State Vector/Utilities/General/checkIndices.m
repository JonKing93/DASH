function[] = checkIndices(var, d, index)
%% Low level error checking for indices for a dimension.

% Get the size of the data
[~,dimID,dimSize] = metaGridfile( var.file );
dimSize = dimSize(d);

% Indices cannot be empty
if isempty( index )
    error('The %s indices of variable %s are empty.', dimID{d}, var.name);
    
% Must be numeric vectors
elseif ~isnumeric(index) || ~isvector(index)
    error('The %s indices of variable %s are not numeric vectors.', dimID{d}, var.name);
    
% Must be positive integers
elseif any(index<=0) || any( mod(index,1)~=0 )
    error('The %s indices of variable %s are not positive integers.', d, var.name);
    
% Cannot be larger than the dimension
elseif any( index>dimSize )
    error('Some %s indices in variable %s are larger than the dimension size.', d, var.name);
end

end