function[] = checkMetadataStructure( meta, dims, errorString )
%% Checks that a dimensional metadata structure is valid.
%
% gridfile.checkMetadataStructure( meta, dims, errorString )
%
% ----- Inputs -----
%
% meta: A metadata structure being tested.
%
% dims: The dimension names allowed in the metadata.
%
% errorString: An identifier for the allowed dimension names for use in an
%    error message.

% Scalar struct
if ~isscalar(meta) || ~isstruct(meta)
    error('meta must be a scalar structure.');
end

% Recognized field names
metaFields = string(fields(meta));
allowed = ismember(metaFields, dims);
if any( ~allowed )
    error('Only %s (%s) are allowed as field names in meta.', errorString, dash.messageList(dims) );
end

% Metadata values
for d = 1:numel(metaFields)
    name = metaFields(d);
    gridfile.checkMetadataField( meta.(name), name );
end

end