function[meta] = assert(meta, dimsList, idHeader)
%% dash.metadata.assert  Throw error if input is not a valid metadata structure
% ----------
%   meta = dash.metadata.assert(meta, dimsList, idHeader)  checks
%   if meta if a valid metadata structure. If not, throws an error with
%   custom error message and identifier. If so, converts cellstring
%   metadata fields to string.
%
%   Valid metadata structures are a scalar structure, only have allowed
%   dimension names, and all fields are valid metadata fields.
% ----------
%   Inputs:
%       meta: The metadata structure being tested
%       dimsList (string vector): A list of allowed dimension names
%       idHeader (string scalar): Header for thrown error IDs
%
%   Outputs:
%       meta: The metadata structure with cellstring metadata fields
%           converted to the string data type.
%
%   Throws:
%       <idHeader>:unallowedMetadataDimension  if meta has fields that are
%           not in the list of allowed dimensions
%
%   <a href="matlab:dash.doc('dash.metadata.assert')">Online Documentation</a>

% Scalar structure
dash.assert.scalarType(meta, 'struct', 'meta', idHeader);

% Recognized field names
metaFields = string(fields(meta));
allowed = ismember(metaFields, dimsList);
if ~all(allowed)
    id = sprintf('%s:unallowedMetadataDimensions', idHeader);
    bad = find(~allowed, 1);
    error(id, ['Metadata field "%s" is not a recognized dimension name. ',...
        'Recognized names are %s'], metaFields(bad), dash.string.list(dims));
end

% Valid metadata fields
for d = 1:numel(metaFields)
    name = metaFields(d);
    meta.(name) = dash.metadata.assertField(meta.(name), name, idHeader);
end

end