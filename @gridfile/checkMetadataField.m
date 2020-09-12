function[meta] = checkMetadataField( meta, dim )
%% Error checks the metadata for a grid dimension. Converts cellstring to
% string.
% 
% meta = gridfile.checkMetadataField(meta, dim)
%
% ----- Input -----
%
% meta: The metadata field being error checked
%
% dim: The name of the dimension associated with the metadata field. (Used
%    for error messages.)
%
% ----- Outputs -----
%
% meta: The metadata field. Cellstrings converted to string.

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
elseif isdatetime(meta) && any( isnat(meta(:)) )
    error('The %s metadata contains NaT elements.', dim );
end

% Convert cellstring to string
if iscellstr(meta) %#ok<ISCLSTR>
    meta = string(meta);
end

% Check there are no duplicate rows. 
if gridfile.hasDuplicateRows(meta)
    error('The %s metadata contains duplicate rows.', dim);
end

end