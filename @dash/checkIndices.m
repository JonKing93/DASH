function[indices] = checkIndices( indices, name, length, lengthName )
%% Checks that an input is a set of indices. Indices may be a logical
% vector the length of a dimension, or a vector of linear indices. Linear
% indices may not exceed the dimension length. Returns custom error
% messages. Converts logical indices to linear indices.
%
% indices = dash.checkIndices( indices, name, length, lengthName )
%
% ----- Inputs -----
%
% indices: The indices being checked.
%
% name: The name of the indices. Used for custom error messages.
%
% length: The length of the array dimension. This is the maximum value
%    for linear indices and the required length of logical indices.
%
% lengthName: The name of the length of the array dimension. A string.
%
% ----- Outputs -----
%
% indices: Linear indices

% Vector
if ~isvector(indices)
    error('%s must be a vector.',name);
end

% Logical indices
if islogical(indices)
    if numel(indices)~=dimLength
        error('%s is a logical vector, but it is not %s (%.f).', name, lengthName, length);
    end
    indices = find(indices);
    
% Numeric indices
elseif isnumeric(indices)
    dash.assertPositiveIntegers(indices, name);
    if max(indices) > dimLength
        error('%s has elements larger than %s (%.f).', name, lengthName, dimLength);
    end
    
% Other types are not allowed
else
    error('%s must either be logical or numeric.');
end

end
