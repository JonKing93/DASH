function[] = checkMetadataField( meta, dim )
%% Error checks the metadata for a grid dimension.
% 
% gridfile.checkMetadataField(meta, dim)
%
% meta: The metadata field
% dim: The name of the dimension

% Type
if ~isnumeric(meta) && ~islogical(meta) && ~ischar(meta) && ...
        ~isstring(meta) && ~iscellstr(meta) && ~isdatetime(meta)
    error('The %s metadata must be one of the following data types: numeric, logical, char, string, cellstring, or datetime', dim);

% Matrix
elseif ~ismatrix(meta)
    error('The %s metadata is not a matrix.', dim );
    
% Illegal elements
elseif isnumeric(meta) && any(isnan(meta(:)))
    error('The %s metadata contains NaN elements.', dim );
elseif isnumeric(meta) && any(isinf(meta(:)))
    error('The %s metadata contains Inf elements.', dim );
elseif isdatetime(meta) && any( isnat(meta(:)) )
    error('The %s metadata contains NaT elements.', dim );
end

% Duplicate rows. Convert cellstring to string for unique with rows option
if gridfile.duplicateRows(meta)
    error('The %s metadata contains duplicate rows.', dim);
end

end