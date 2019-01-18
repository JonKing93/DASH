function[] = compareMetadata( m, meta, ic )
%% Compares two metadata structures. Throws error if they do not match at
% specified indices.
%
% compareMetadata( m, meta, ic )
%
% ----- Inputs -----
%
% m: A metadata structure for a full gridded .mat file.
%
% meta: A metadata structure for specific indices.
%
% ic: A cell of indices specifying metadata indices in m.

% Get the existing metadata
oldMeta = m.meta;
dimID = m.dimID;

% Check the indexed values match in the metadata
for d = 1:numel(dimID)
    % Check that the dimension is in the metadata.
    if ~isfield( meta, dimID{d})
        error('The new metadata does not contain the %s field', dimID{d});
    end
    
    % Convert to cell column
    if isrow(meta.(dimID{d}))
        meta.(dimID{d}) = meta.(dimID{d})';
    end
    if ~iscell(meta.(dimID{d}))
        meta.(dimID{d}) = num2cell( meta.(dimID{d}) );
    end
    
    % Check that the new metadata matches the old   
    if ~isequaln( oldMeta.(dimID{d})(ic{d}), meta.(dimID{d}) )
        error('Metadata for %s does not match the values in the existing file.', dimID{d});
    end
end

% Also ensure that the var field matches
[~, var] = getKnownIDs;
if ~isfield(meta, var)
    error('The new metadata does not contain the ''%s'' field', var);
elseif ~isequal( oldMeta.(var), meta.(var) )
    error('The metadata ''var'' field does not match the existing file.');
end

end