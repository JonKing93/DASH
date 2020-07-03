function[] = checkMetadataStructure( meta )
%% Checks that a dimensional metadata structure is valid.
%
% gridfile.checkMetadataStructure( meta )

% Scalar struct
if ~isscalar(meta) || ~isstruct(meta)
    error('meta must be a scalar structure.');
end

% Recognized field names
metaFields = string(fields(meta));
allowed = ismember(metaFields, dash.dimensionNames);
if any( ~allowed )
    error('The field "%s" in meta is not allowed. Only recognized dimension names are allowed as field names in meta. (See dash.dimensionNames)', metaFields(find(~allowed,1)) );
end

% Metadata values
for d = 1:numel(metaFields)
    name = metaFields(d);
    gridfile.checkMetadataField( meta.(name), name );
end

end