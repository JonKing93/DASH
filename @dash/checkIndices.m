function[indices] = checkIndices( indices, name, dimLength, dimName )
%% Checks that an input is a set of indices. Indices may be a logical
% vector the length of a dimension, or a vector of linear indices. Linear
% indices may not exceed the dimension length. Returns custom error
% messages. Converts logical indices to linear indices.
%
% indices = dash.checkIndices( indices, name, dimLength, dimName )
%
% ----- Inputs -----
%
% indices: The indices being checked.
%
% name: The name of the indices. Used for custom error messages.
%
% dimLength: The length of the dimension for the indices.
%
% dimName: The name of the dimension.
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
        error('%s is a logical vector, but it is not the length of the %s dimension (%.f).', name, dimName, dimLength);
    end
    indices = find(indices);
    
% Numeric indices
elseif isnumeric(indices)
    dash.assertPositiveIntegers(indices, false, false, name);
    if max(indices) > dimLength
        error('%s has elements larger than the length of the %s dimension (%.f).', name, dimName, dimLength);
    end
    
% Other types are not allowed
else
    error('%s must either be logical or numeric.');
end

end
