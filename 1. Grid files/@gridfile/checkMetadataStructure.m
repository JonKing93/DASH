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
recognized = ismember(metaFields, dash.dimensionNames);
if any( ~recognized )
    error('The field "%s" in meta is not allowed. Only recognized dimension names are allowed as field names in meta. (see dash.dimensionNames for the list of recognized dimension names).', metaFields(find(~recognized,1)) );
end

% Metadata values
for d = 1:numel(metaFields)
    name = metaFields(d);
    gridfile.checkMetadataField( meta.(name), name );
end

end