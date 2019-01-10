function[] = checkIndices(var, d, index)
%% Low level error checking for indices for a dimension.

% Get the size of the data
[~,~,dimSize] = metaGridfile( var.file );
dimSize = dimSize(d);

% Indices cannot be empty
if isempty( index )
    error('The %s indices are empty.', d);
    
% Must be numeric vectors
elseif ~isnumeric(index) || ~isvector(index)
    error('The %s indices must be numeric vectors.', d);
    
% Must be positive integers
elseif any(index<=0) || any( mod(index,1)~=0 )
    error('The %s indices must be positive integers.', d);
    
% Cannot be larger than the dimension
elseif any( index>dimSize )
    error('Some %s indices are larger than the dimension size.', d);
end

end