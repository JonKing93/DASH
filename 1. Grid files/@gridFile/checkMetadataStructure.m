function[] = checkMetadataStructure( meta )
%% Checks that a metadata structure is valid.
%
% gridfile.checkMetadataStructure( meta )

% Scalar struct
if ~isscalar(meta) || ~isstruct(meta)
    error('meta must be a scalar structure.');
end

% Recognized field names
metaFields = string( fields(meta) );
recognized = [dash.dimensionNames, gridfile.attributesName];
if any( ~ismember(metaFields, recognized) )
    error('meta contains unrecognized fields. Allowed fields are dimension names (see dash.dimensionNames) and "%s"', gridfile.attributesName);
end

% Metadata values
for d = 1:numel(metaFields)
    name = metaFields(d);
    if ~strcmp(name, gridfile.attributesName)
        gridfile.checkMetadataField( meta.(name), name );
    end
end

end