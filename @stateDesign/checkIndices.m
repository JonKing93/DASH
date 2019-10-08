function[index] = checkIndices( obj, index, v, d )
% Error check indices and place in a common format for internal use.

% If a logical, must be a vector the length of the dimension
if islogical(index)
    
    % Must be a vector the length of the dimension
    if ~isvector(index) || numel(index)~=obj.var(v).dimSize(d)
        error('Logical indices must be a vector the length of the dimension.');
    end
    
    % Convert to linear
    index = find( index );
    
    
% Otherwise, should be linear indices. Do some error checking.
else
    if isempty( index )
        error('The indices for the %s dimension of variable %s are empty.', obj.var(v).dimID(d), obj.varName(v));
    elseif ~isnumeric(index) || ~isvector(index)
        error('The indices for the %s dimension of variable %s are not numeric vectors.', obj.var(v).dimID(d), obj.varName(v));
    elseif any(index<=0) || any( mod(index,1)~=0 )
        error('The indices for the %s dimension of variable %s are not positive integers.', obj.var(v).dimID(d), obj.varName(v));
    elseif any( index>obj.var(v).dimSize(d) )
        error('Some indices for the %s dimension in variable %s are larger than the dimension size.', obj.var(v).dimID(d), obj.varName(v));
    end
end

% Convert to sorted column
index = sort( index(:) );

end