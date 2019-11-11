function[fullSCS, keep] = unmergeSCS( obj, scs )
% Modifies scs to account for merged dimensions. Returns keep indices for
% the fully loaded merged dimension.

% Get the sets of merged dimensions
mergeSet = obj.mergeSet( ~isnan(obj.mergeSet) );
nSet = numel(mergeSet);
nMerged = numel( obj.size );
nUnmerged = numel( obj.unmergedSize );

% Preallocate scs and keep for the full, unmerged load. Get the indices to
% extract from the remerged load.
fullSCS = NaN( 3, nUnmerged );
keep = repmat( {':'}, [1, nMerged] );

% For each merge set
for m = 1:nSet
    
    % Get the index of the merged dimension, covert scs to linear indices
    dm = (mergeSet(m) == obj.mergeSet);
    indices = (scs(1,dm) : scs(3,dm) : scs(1,dm)+scs(3,dm)*(scs(2,dm)-1))';
    
    % Get the indices of unmerged dims, convert linear to subscript
    dum = find(mergeSet(m) == obj.merge);
    siz = obj.unmergedSize( dum );
    nDim = numel(dum);
    
    subIndex = cell(1, nDim);
    [subIndex{:}] = ind2sub( siz, indices );
    
    % Get scs for each dimension in the merge set. Adjust the subIndex for
    % the new start and count
    for d = 1:nDim
        subSort = unique( sort( subIndex{d} ) );
        fullSCS(:,dum(d)) = loadKeep( subSort );
        subIndex{d} = ( (subIndex{d} - fullSCS(1,dum(d))) / fullSCS(3,dum(d)) ) + 1;
    end
    
    % Get the extracted indices from the remerged data
    siz = fullSCS(2, dum);
    keep{dm} = sub2ind( siz, subIndex{:} ); 
    
end

% Add back the scs for dimensions that are not part of a merge set
noSet = isnan( obj.mergeSet );
noMerge = isnan( obj.merge );
fullSCS(:,noMerge) = scs(:, noSet);

end