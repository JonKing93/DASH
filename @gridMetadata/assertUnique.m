function[] = assertUnique(obj, header)

% Default
if ~exist('header','var') || isempty(header)
    header = 'DASH:gridMetadata:assertUnique';
end

% Get the metadata for each defined dimension
dims = obj.defined;
for d = 1:numel(dims)
    dim = dims(d);
    meta = obj.(dim);
    
    % Throw error if rows are not unique
    [areUnique, repeats] = dash.is.uniqueSet(meta, true);
    if ~areUnique
        id = sprintf('%s:duplicateRows', header);
        error(id, 'The "%s" metadata has duplicate rows. (Rows %s)',...
            dim, dash.string.list(repeats));
    end
end

end