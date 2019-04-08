function[] = setGridMetadata( file, dim, meta )
%% This changes the values in a metadata field for an existing gridfile.
%
% setGridMetadata( file, dim, gridMeta )
%
% ----- Inputs -----
%
% file: The name of a .grid file
%
% dim: The metadata field being edited
%
% meta: The new metadata

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check that dim is a string flag
if ~isstrflag(dim)
    error('dim must be a string flag');
end

% Error check the file
m = fileCheck(file);

% Get the metadata
gridMeta = m.meta;

% Check for the metadata field
if ~isfield(gridMeta, dim)
    error('%s is not a field in the metadata.', dim);
end

% If this is the variable specs, ensure it is a scalar
[~,varSpec] = getDimIDs;
if strcmp(dim, varSpec) && ~isscalar(meta)
    error('Metadata for the %s field must be a scalar.', varSpec);
end

% Check that the size of the first metadata dimension matches the size of
% grid dimension
d = find( ismember(dim, m.dimID) );
if size(gridMeta,1) ~= m.gridSize(d)
    error('The first dimension of the metadata must have %0.f elements.', m.gridSize(d));
end

% Set the new grid metadata
gridMeta.(dim) = meta;
m.meta = gridMeta;

end