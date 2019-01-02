function[] = compareMetadata( m, meta, ic )

% Get the existing metadata
oldMeta = m.meta;
dimID = m.dimID;

% Check the indexed values match in the metadata
for d = 1:numel(dimID)
    if ~isfield( meta, dimID{d})
        error('The new metadata does not contain the %s field', dimID{d});
    elseif ~isequaln( oldMeta.(dimID{d})(ic{d}), meta.(dimID{d}) ) && ...
            ~isequaln( oldMeta.(dimID{d})(ic{d})', meta.(dimID{d}) )
        error('Metadata for %s does not match the values in the existing file.', dimID{d});
    end
end

% Also ensure that the var field matches
if ~isfield(meta, 'var')
    error('The new metadata does not contain the ''var'' field');
elseif ~isequal( oldMeta.var, meta.var )
    error('The metadata ''var'' field does not match the existing file.');
end

end