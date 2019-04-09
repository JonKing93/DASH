function[] = setGridMetadata( file, dim, newMeta )
%% This changes the values in a metadata field for an existing gridfile.
%
% setGridMetadata( file, dim, newMeta )
%
% ----- Inputs -----
%
% file: The name of a .grid file
%
% dim: The dimension being given new metadata
%
% newMeta: The new metadata

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error checking. Get a matfile object
m = fileCheck(file);
checkDim(dim);

% Get the grid metadata
gridMeta = m.meta;

% Check for the metadata field
if ~isfield(gridMeta, dim)
    error('The %s dimension is not in the grid metadata.', dim);
end

% If this is the variable specs, ensure it is a scalar
[~,spec] = getDimIDs;
if strcmp(dim, spec) && ~isscalar(newMeta)
    error('Metadata for the "%s" field must be a scalar.', spec);
end

% Get the number of elements in the dimension
nEls = m.gridSize( strcmp(dim, m.dimID) );

% Check that the new metadata has the correct size
newMeta = checkMetadataRows(newMeta, nEls);

% Set the new grid metadata
gridMeta.(dim) = newMeta;
m.meta = gridMeta;

end