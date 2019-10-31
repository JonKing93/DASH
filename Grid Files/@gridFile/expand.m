function[] = expand( file, dim, newMeta )
%% Expands a .grid file along a specified dimension.

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
m = matfile( file );
metadata = m.metadata;
if isnan( metadata.(dim) )
    error('The metadata for the %s dimension in the file %s is NaN. Please write in a non-NaN value first. (See gridFile.rewriteMeta)', dim, file);
end

% Check that the new metadata can be appended
try
    allmeta = cat(1, metadata.(dim), newMeta );
catch ME
    error('The new metadata cannot be appended to the existing metadata.');
end
   
% Check the new metadata does not duplicate the old
if size(allmeta,1) ~= size( unique(allmeta, 'rows'), 1 )
    error('The new metadata duplicates existing metadata values.');
end

% Add the new metadata to the file
metadata.(dim) = allmeta;
m.metadata = metadata;

end