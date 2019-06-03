function[] = rewriteGridMetadata( file, dim, newMeta )
%% This changes the values in a metadata field for an existing gridfile.
%
% setGridMetadata( file, dim, newMeta )
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
%          dimension in the gridded data. If overwriting variable
%          attributes, a scalar structure whose fields contain the
%          attribute metadata being overwritten. Each field must contain a
%          vector of a valid NetCDF4 data type.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error checking.
fileCheck(file);
checkDim(dim);

% Get the grid metadata
meta = metaGridfile( file );

% Check for the metadata field
if ~isfield(meta, dim)
    error('The %s dimension is not in the grid metadata.', dim);
end

% If this is the variable attributes
[~,spec] = getDimIDs;
if strcmp(dim, spec)
    
    % Check that the values are valid
    checkValidSpecs( value );
    
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
    newMeta = checkMetadata( newMeta, nEls, dim );

    % Set the new grid metadata
    ncwrite( file, dim, newMeta );
end

end