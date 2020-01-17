function[] = rewriteMetadata( obj, dim, newMeta )
%% Rewrites the metadata in a .grid file along a specified dimension.
%
% obj.rewriteMetadata( dim, newMeta )
%
% ----- Inputs -----
%
% dim: The name of the dimension for which metadata is being rewritten.
%
% newMeta: The new metadata. Must have one row per element along the
%          dimension.

% Update in case the matfile changed
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
elseif size( newMeta, 1) ~= size( unique(newMeta,'rows'), 1)
    error('The new metadata contains duplicate rows.');
end
 
% Check the new metadata is the correct size
if size(newMeta,1) ~= size( obj.metadata.(dim), 1 )
    error('The new metadata must have %.f rows.', size(obj.metadata.(dim),1) );
end

% Get the updated field
obj.metadata.(dim) = newMeta;

% Write to file
try
    m = matfile( obj.filepath, 'Writable', true );
    m.valid = false;
    m.metadata = obj.metadata;
    m.valid = true;
    
% Delete the object if the write fails
catch
    [~, killStr] = fileparts( obj.filepath );
    delete( obj );
    error('Failed to add new data source. The file %s is no longer valid. Deleting the current gridFile object.', killStr);
end

end