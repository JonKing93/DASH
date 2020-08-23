function[d] = findDimIndices( obj, v, dim )
% Get the dimension indices of named dimensions.

% Ensure that dim is a string scalar. Convert to "string" for internal use
if ~isstrlist( dim )
    error('dim must be a character row vector, cellstring, or string vector.');
end
dim = string(dim);

% Get the indices
[ismem, d] = ismember( dim, obj.var(v).dimID );

% Throw error if not a dimension
if any(~ismem)
    error('%s is not a dimension in the state design.', dim(find(~ismem,1)) );
end

end

