function[] = checkAppendMetadata( newMeta, oldMeta, dimLen )
%% Checks that new metadata can be appended to old metadata. Checks that no
% duplicates occur, and that there is one metadata row for each new index.

% Stop if the metadata is NaN. (user needs to add metadata so there are no
% NaN elements in this dimension.)
if isnan( oldMeta )
    error('There is no metadata for the %s dimension. Add some using rewriteGridMetadata.m before appending along this dimension.', dim);
end

% Check that the class of the new metadata matches the old class
oldClass = class( oldMeta );
newClass = class( newMeta );
if ~strcmp( oldClass, newClass )
    error('The data type of the pre-existing metadata (%s) does not match the data type of the new metadata (%s).', oldClass, newClass );
end

% Check that the new metadata has one row per element along the appending
% dimension
if size(newMeta,1) ~= dimLen
    
    % Get a toggle to improve the error message
    type = 'rows';
    if isvector( newMeta )
        type = 'elements';
    end
    
    error('The number of %s in the new metadata (%.f) does not match the length of the %s dimension in the new data (%.f).', ...
           type, size(newMeta,1), dim, dimLen(d) );
end

% Check that the number of columns in the new metadata matches the number
% in the old metadata
if size(oldMeta,2) ~= size(newMeta,2)
    if isvector(newMeta)
        error('The pre-existing metadata is a matrix, but the new metadata is a vector.');
    else
        error('The number of columns in the new metadata (%.f) does not match the number for the pre-existing metadata (%.f).', size(newMeta,2), size(oldMeta,1) );
    end
end
    
% Check that there are no duplicate metadata values in the new metadata
if size( [oldMeta;newMeta], 1 ) ~= size( unique( [oldMeta;newMeta], 'rows' ), 1 )
    error('The new metadata duplicates values in the pre-existing metadata.');
end

end