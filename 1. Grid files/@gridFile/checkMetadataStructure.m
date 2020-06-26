function[] = checkMetadataStructure( meta )
%% Checks that a dimensional metadata structure is valid.
%
% gridfile.checkMetadataStructure( meta )

% Scalar struct
if ~isscalar(meta) || ~isstruct(meta)
    error('meta must be a scalar structure.');
end

% Recognized field names
metaFields = fields(meta);
if any( ~ismember(metaFields, dash.dimensionNames) )
    error('meta contains unrecognized fields. Allowed fields are dimension names (see dash.dimensionNames).');
end

% Metadata values
for d = 1:numel(metaFields)
    name = metaFields(d);
    gridfile.checkMetadataField( meta.(name), name );
end

end