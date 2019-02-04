function[] = newGridfile( file, gridData, gridDims, meta )
%% Creates a new gridded .mat file.
%
% newGridfile( file, gridData, gridDims, meta )
% Creates a new gridded .mat file. Checks that metadata matches data size
% in all dimensions.
%
% ----- Inputs -----
%
% file: The name of the gridded .mat file. A string.
%
% gridData: A gridded data set.
%
% gridDims: A cell of dimension IDs indicating the order of dimensions in
%       the gridded data.
%
% meta: A metadata structure for the gridded data. See the buildMetadata.m
%       function.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check that the file is a string
if ~isstrflag(file)
    error('File name must be a string.');
end
file = char(file);
if numel(file)<5 || ~strcmp( file(end-4:end), '.grid' )
    error('File must end in a .grid extension.');
end

% Get the size of all non-trailing singletons
gridSize = size(gridData);
if iscolumn(gridData)
    gridSize = gridSize(1);
end
minDim = numel(gridSize);

% Ensure all dimensions that are not trailing singletons have IDs
if numel(gridDims) < minDim
    error('All dimensions that are not a trailing singleton must have IDs.');
end

% Get the known dimension IDs
[knownID, var] = getKnownIDs;

% Permute the knownIDs to match the data ordering
permDex = getPermutation( knownID, gridDims, knownID );
dimID = knownID(permDex);

% Then permute the data from smallest to largest dimension to optimize
% use with matfile indexing.
gridSize = fullSize(gridData, numel(dimID));
[gridSize, permDex] = sort( gridSize, 'ascend' );

gridData = permute( gridData, permDex );
dimID = dimID(permDex);

% Error check the metadata
if any( ~isfield(meta, [dimID, var]) )
    error('Metadata does not contain all required fields.');
elseif ~( (isstring(meta.(var)) && isscalar(meta.(var))) || (ischar(meta.(var)) && isvector(meta.(var))) )
    error('The %s field of the metadata must be a string ID.', var);
end

% Convert all metadata to cell arrays
for d = 1:numel(dimID)        
    if ~isvector( meta.(dimID{d}) )
        error('Metadata field %s must be a vector.', dimID{d});
    elseif length( meta.(dimID{d}) ) ~= gridSize(d)
        error('Metadata for %s does not match the size of the dimension in the gridded data.', dimID{d});
    end
    
    % Convert all metadata to column arrays
    if isrow( meta.(dimID{d}) )
        meta.(dimID{d}) = meta.(dimID{d})';
    end
end

% Save a v7.3 matfile to enable partial loading
save(file, 'gridData', 'gridSize', 'dimID', 'meta', '-mat', '-v7.3');

end