function[] = expand( obj, dim, newMeta )
%% Increases the size of a dimension in a .grid File
%
% obj.expand( dim, newMeta )
%
% ----- Inputs -----
%
% file: A .grid file.
%
% dim: The name of the dimension being expanded. A string
%
% newMeta: New metadata for the dimension. Must have one row per new
%          element along the dimension.

% Update in case changes were made
obj.update;

% Check the dim is an ID
if ~isstrflag( dim )
    error('dim must be a string scalar or character row vector.');
elseif ~ismember( dim, getDimIDs )
    error('dim is not a recognized dimension ID.');
end

% Check the new metadata is allowed
 if ~gridFile.ismetadatatype( newMeta )
    error('The new metadata must be one of the following datatypes: numeric, logical, char, string, cellstring, or datetime');
elseif iscellstr( newMeta ) %#ok<ISCLSTR>
    error('The new metadata is a cellstring.');
elseif ~ismatrix( newMeta )
    error('The new metadata is not a matrix.' );
elseif isnumeric( newMeta ) && any(isnan(newMeta(:)))
    error('The new metadata contains NaN elements.' );
elseif isnumeric( newMeta) && any(isinf(newMeta(:)))
    error('The new metadata contains Inf elements.' );
elseif isdatetime(newMeta) && any( isnat(newMeta(:)) )
    error('The new metadata contains NaT elements.' );
end

% Check the old metadata is not a NaN singleton
if isscalar(obj.metadata.(dim)) && isnumeric(obj.metadata.(dim)) && isnan( obj.metadata.(dim) )
    error('The metadata for the %s dimension in the file %s is NaN. Please write in a non-NaN value first. (See gridFile.rewriteMetadata)', dim, file);
end

% Check that the new metadata can be appended
if size( obj.metadata.(dim),2) ~= size(newMeta, 2)
    error('The new %s metadata has a different number of columns than the metadata in file %s.', dim, file );
elseif (isnumeric(newMeta) || islogical(newMeta)) && ~(isnumeric(obj.metadata.(dim)) || islogical(obj.metadata.(dim)))
    error('The new %s metadata is numeric or logical, but the metadata in the %s file is not.', dim, file );
elseif isstrlist(newMeta) && ~isstrlist(obj.metadata.(dim))
    error('The new %s is a string, but the metadata in the %s file is not.', dim, file );
end
try
    allmeta = cat(1, obj.metadata.(dim), newMeta );
catch ME
    error('The new metadata cannot be appended to the existing metadata. It may be a different type.');
end
   
% Check the new metadata does not duplicate the old or itself
if size(allmeta,1) ~= size( unique(allmeta, 'rows'), 1 )
    error('The new metadata duplicates existing metadata values.');
end

% Update the fields
obj.metadata.(dim) = allmeta;
d = find(  strcmp(dim, obj.dimOrder) );
obj.gridSize(1,d) = size(allmeta,1);

% Write to file
try
    m = matfile( obj.filepath, 'Writable', true );
    m.valid = false;
    m.gridSize(1,d) = obj.gridSize(1,d);
    m.metadata = obj.metadata;
    m.valid = true;
    
% Delete the object if the write fails
catch
    [~, killStr] = fileparts( obj.filepath );
    delete( obj );
    error('Failed to add new data source. The file %s is no longer valid. Deleting the current gridFile object.', killStr);
end

end