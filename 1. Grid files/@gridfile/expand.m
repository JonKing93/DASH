function[] = expand( obj, dim, meta )
%% Increases the length of a dimension in a .grid file and defines metadata 
% for the new elements along the dimension.
%
% obj.expand( dim, meta )
%
% ----- Inputs -----
%
% dim: The name of the dimension being expanded. A string. The dimension
%    must already have defined metadata in the .grid file.
%
% meta: New metadata values for the dimension. A numeric, logical,
%    char, string, cellstring, or datetime matrix. Must have one row for
%    each new elements along the dimension. Each row must be unique and
%    cannot contain NaN, Inf, or NaT elements. Must have one column for
%    each column in the existing .grid file metadata. It must be possible
%    to append the data type of the new metadata to the data type of the
%    existing metadata in the .grid file. Compatible types are
%    (numeric/logical), (char/string/cellstring), and (datetime).

% Update in case the file was changed.
obj.update;

% Error check
dash.assertStrFlag(dim, "dim");
obj.checkAllowedDims(dim);
obj.checkMetadataField(meta, dim);

% Check that the dimension has defined metadata in the .grid file.
oldMeta = obj.meta.(dim);
if isscalar(oldMeta) && isnumeric(oldMeta) && isnan(oldMeta)
    error('The %s metadata in .grid file %s has not been defined. Please define metadata for this dimension first (see gridfile.rewriteMetadata).', dim, obj.file);
end

% Check that the new metadata can be appended to the old
if size(meta,2) ~= size(oldMeta,2)
    error('The new %s metadata has a different number of columns than the %s metadata in .grid file %s.', dim, dim, obj.file );
elseif (isstring(meta) || iscellstr(meta) || ischar(meta)) && ...
        ~(isstring(oldMeta) || iscellstr(oldMeta) || ~ischar(oldMeta))
    error('The new %s metadata is a string, char, or cellstring, but the %s metadata in .grid file %s is not.', dim, dim, obj.file);
elseif (isnumeric(meta) || islogical(meta)) && ~(isnumeric(oldMeta) || islogical(oldMeta))
    error('The new %s metadata is numeric or logical, but the %s metadata in .grid file %s is not.', dim, dim, obj.file );
elseif isdatetime(meta) && ~isdatetime(oldMeta)
    error('The new %s metadata is datetime, but the %s metadata in .grid file %s is not.', dim, dim, obj.file);
end
try
    meta = cat(1, oldMeta, meta);
catch
    error('The new %s metadata cannot be appended to the existing %s metadata in .grid file %s.', dim , dim, obj.file);
end

% Check that the new metadata does not duplicate rows in the old metadata
if gridfile.hasDuplicateRows(meta)
    error('The new %s metadata duplicates rows in the existing %s metadata in .grid file %s.', dim, dim, obj.file);
end

% Update the metadata. Convert from cellstring. Update size.
obj.updateMetadataField(dim, meta);

end