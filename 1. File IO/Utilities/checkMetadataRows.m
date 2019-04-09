function[meta] = checkMetadataRows( meta, nRows, dim )
%% Ensures that metadata has the correct number of rows

% Convert row vector to column if the number of elements is correct
if isrow(meta) && length(meta) == nRows
    meta = meta';
    
% Throw error if the number of rows is incorrect
elseif size(meta,1) ~= nRows
    
    % If a dimension is provided, improve the error message
    str = '';
    if exist('dim','var')
        str = sprintf('for the %s dimension ', dim);
    end
    
    error('The number of rows in the metadata (%.f) %sdoes not match the number of indices (%.f)', size(meta,1), str, nRows);
end

end