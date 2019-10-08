function[] = rewriteMeta( file, dim, newMeta )
%% This changes the values in a metadata field for an existing gridfile.
%
% gridFile.rewriteMeta( file, dim, newMeta )
%
% ----- Inputs -----
%
% file: The name of a .grid file
%
% dim: The dimension being given new metadata. Either a dimension ID or the
%      name of the variable attributes dimension (the second output of 
%      getDimIDs.m).
%
% newMeta: The new metadata. If dimensional metadata, either a vector or
%          matrix of a valid NetCDF4 data type. The number of elements
%          (rows) in the vector (matrix) must match the length of the
%          dimension in the gridded data. The class of the new metadata
%          must match the class of the existing metadata. If overwriting variable
%          attributes, use a scalar structure (specs) whose fields contain the
%          attribute metadata being overwritten. Each field must contain a
%          vector of a valid, numeric NetCDF4 data type. (See listnctypes.m)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error checking.
gridFile.fileCheck(file);
gridFile.checkDim(dim, true);

% Get the grid metadata
meta = gridFile.meta( file );

% Check for the metadata field
if ~isfield(meta, dim)
    error('The %s dimension is not in the grid metadata. The getDimIDs function may have been altered.', dim);
end

% If this is the variable attributes
[~,spec] = getDimIDs;
if strcmp(dim, spec)
    
    % Check that the values are valid
    gridFile.checkValidSpecs( value );
    
    % Write to the grid file
    specField = string(fieldnames(meta.(spec)));
    for f = 1:numel(specField)
        ncwriteatt( file, 'gridData', specField(f), meta.(specs).(specField(f)) );
    end
    
% Otherwise, this is dimensional metadata
else

    % Get the number of elements in the dimension
    nEls = size( meta.(dim), 1 );

    % Check that the metadata is valid
    newMeta = gridFile.checkMetadata( newMeta, nEls, dim );
    
    % Check that the new metadata matches the old data class
    if ~strcmp( class(newMeta), class(meta.(dim)) )
        error('The data type of the new metadata (%s) is different than the old metadata (%s).', class(newMeta), class(meta.(dim)) );
    end

    % Set the new grid metadata
    ncwrite( file, dim, newMeta );
end

end