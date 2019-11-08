function[X] = mergeDims( X, merge )

% For each set of merged dimension
mergeSet = unique( merge(~isnan(merge))  );
dimIndex = 1:numel(merge);
for m = 1:numel(mergeSet)
    
    % Get the dimensions being merged and permute to front
    dims = ( mergeSet(m) == merge );
    permOrder = [dimIndex(dims), dimIndex(~dims)];
    X = permute( X, permOrder );
    
    % Reshape the merged dims. Replace secondary dimensions with singletons
    % to preserve dimension order
    siz = size(X);
    nMerge = sum(dims);
    X = reshape( X, [prod(siz(1:nMerge)), ones(1,nMerge-1), siz(nMerge+1:end)] );
    
    % Unpermute
    [~, unorder] = sort( permOrder );
    X = permute( X, unorder );
end

% Remove the merged singletons
X = squeeze(X);

end
    
    