function[] = checkMetadata( meta )
%% Checks that metadata structure is valid. 

if ~isscalar(meta) || ~isstruct(meta)
    error('meta must be a scalar structure.');
end

metaDims = string( fields(meta) );
dimID = getDimIDs;
if any( ~ismember( metaDims, dimID ) )
    error('The metadata contains fields that are not recognized dimension IDs.')p
end

for d = 1:numel(metaDims)
    value = meta.(metaDims(d));
    
    if ~gridFile.ismetadatatype( value )
        error('The %s metadata must be one of the following datatypes: numeric, logical, char, string, cellstring, or datetime', metaDims(d));
    elseif iscellstr( value ) %#ok<ISCLSTR>
        error('The %s metadata is a cellstring.', metaDims(d) );
    elseif ~ismatrix( value )
        error('The %s metadata is not a matrix.', metaDims(d) );
    elseif isnumeric( value ) && any(isnan(value(:)))
        error('The %s metadata contains NaN elements.', metaDims(d) );
    elseif isnumeric( value) && any(isinf(value(:)))
        error('The %s metadata contains Inf elements.', metaDims(d) );
    elseif isdatetime(value) && any( isnat(value(:)) )
        error('The %s metadata contains NaT elements.', metaDims(d) );
    end
    
    if size(value,1) ~= size( unique(value, 'rows'), 1 )
        error('The %s metadata contains duplicate values.', metaDims(d));
    end
    
end

end