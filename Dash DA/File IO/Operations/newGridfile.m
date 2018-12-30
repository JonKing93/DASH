%% This creates a new .mat file.
function[] = newGridfile( file, gridData, gridDims, meta )

% Check that the file is a .mat file
if isstring(file)
    file = char(file);
end
if ~strcmp( file(end-3:end), '.mat' )
    error('The file must be a .mat file.');
end

% Get the known dimension IDs
knownID = getKnownIDs;

% Permute the knownIDs to match the data ordering
permDex = getPermutation( knownID, gridDims, knownID );
dimID = knownID(permDex);

% Then permute the data from smallest to largest dimension to optimize
% use with matfile indexing.
sData = fullSize(gridData, numel(dimID));
[sData, permDex] = sort( sData, 'ascend' );

gridData = permute( gridData, permDex );
dimID = dimID(permDex);

% Error check the metadata
if any( ~isfield(meta, [dimID, 'var']) )
    error('Metadata does not contain all required fields.');
elseif ~( (isstring(meta.var) && isscalar(meta.var)) || (ischar(meta.var) && isvector(meta.var)) )
    error('The ''var'' field of the metadata must be a string ID.');
end
for d = 1:numel(dimID)        
    if ~isvector( meta.(dimID{d}) )
        error('Metadata field %s must be a vector.', dimID{d});
    elseif length( meta.(dimID{d}) ) ~= sData(d)
        error('Metadata for %s does not match the size of the dimension in the gridded data.', dimID{d});
    end
end

% Save a v7.3 matfile to enable partial loading
save(file, 'gridData', 'dimID', 'meta', '-v7.3');

end