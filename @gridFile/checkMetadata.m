function[value] = checkMetadata( value, nRows, dim )
%% Checks that metadata is a valid format. That is: a valid NetCDF4 data type,
% a matrix, cannot contain NaN, and cannot contain duplicate values.
%
% Also checks that the number of rows is correct. If a row vector with the
% exact number of elements, converts to a column vector.

% Check that the metadata is an allowed type
if ~gridFile.isnctype( value )
    error('The %s metadata is a "%s" datatype, which is not allowed. Please see listnctypes.m for the allowed data types.', dim, class(value));
elseif ~ismatrix( value )
    error('The %s metadata is not a matrix.', dim );
elseif any(isnan(value(:)))
    error('The %s metadata contains NaN elements.', dim );
elseif any(isinf(value(:)))
    error('The %s metadata contains Inf elements.', dim );
end

% Convert row vector to column if the number of elements is correct
if isrow(value) && length(value) == nRows
    value = value';
    
% Otherwise, throw error if the number of rows is incorrect
elseif size(value, 1) ~= nRows
    error('The number of rows in the %s metadata (%.f) does not match the number of indices in the dimension (%.f).', dim, size(value,1), nRows);
end

% Check there are no duplicate rows
if size(value,1) ~= size( unique(value, 'rows'), 1 )
    error('The %s metadata contains duplicate values.', dim);
end

end