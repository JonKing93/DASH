function[] = rewriteMetadata( file, dim, newMeta )
%% Rewrites the metadata in a .grid file along a specified dimension.
%
% gridFile.rewriteMetadata( file, dim, newMeta )
%
% ----- Inputs -----
%
% file: The name of a .grid file. A string.
%
% dim: The name of the dimension for which metadata is being rewritten.
%
% newMeta: The new metadata. Must have one row per element along the
%          dimension.

% Check the file is .grid and exists
gridFile.fileCheck( file );
m = matfile( file, 'writable', true );

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
elseif size( newMeta, 1) ~= size( unique(newMeta,'rows'), 1)
    error('The new metadata contains duplicate rows.');
end
 
% Check the new metadata is the correct size
metadata = m.metadata;
if size(newMeta,1) ~= size( metadata.(dim), 1 )
    error('The new metadata must have %.f rows.', size(metadata.(dim),1) );
end

% Write
metadata.(dim) = newMeta;
m.valid = false;
m.metadata = metadata;
m.valid = true;

end