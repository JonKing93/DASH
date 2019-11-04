function[] = expand( file, dim, newMeta )
%% Increases the size of a dimension in a .grid File
%
% gridFile.expand( file, dim, newMeta )
%
% ----- Inputs -----
%
% file: A .grid file.
%
% dim: The name of the dimension being expanded. A string
%
% newMeta: New metadata for the dimension. Must have one row per new
%          element along the dimension.

% Check the file is .grid and exists.
gridFile.fileCheck( file );

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
m = matfile( file, 'writable', true );
metadata = m.metadata;
if isscalar(metadata.(dim)) && isnumeric(metadata.(dim)) && isnan( metadata.(dim) )
    error('The metadata for the %s dimension in the file %s is NaN. Please write in a non-NaN value first. (See gridFile.rewriteMetadata)', dim, file);
end

% Check that the new metadata can be appended
if size( metadata.(dim),2) ~= size(newMeta, 2)
    error('The new %s metadata has a different number of columns than the metadata in file %s.', dim, file );
elseif (isnumeric(newMeta) || islogical(newMeta)) && ~(isnumeric(metadata.(dim)) || islogical(metadata.(dim)))
    error('The new %s metadata is numeric or logical, but the metadata in the %s file is not.', dim, file );
elseif isstrlist(newMeta) && ~isstrlist(metadata.(dim))
    error('The new %s is a string, but the metadata in the %s file is not.', dim, file );
end
try
    allmeta = cat(1, metadata.(dim), newMeta );
catch ME
    error('The new metadata cannot be appended to the existing metadata. It may be a different type.');
end
   
% Check the new metadata does not duplicate the old or itself
if size(allmeta,1) ~= size( unique(allmeta, 'rows'), 1 )
    error('The new metadata duplicates existing metadata values.');
end

% Add the new metadata to the file
metadata.(dim) = allmeta;
d = find(  strcmp(dim, m.dimOrder) );

m.valid = false;
m.gridSize(1,d) = size(allmeta,1); %#ok<FNDSB>
m.metadata = metadata;
m.valid = true;

end