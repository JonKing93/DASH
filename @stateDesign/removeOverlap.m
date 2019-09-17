function[subDraws] = removeOverlap( obj, subDraws, cv )
% Remove overlapping draws for a set of coupled variables

% Get the ensemble dimensions. Iterate through all the variables (because
% the variables may have different spacing in different dimensions).
ensDim = find( ~obj.var(cv(1)).isState );
nDim = numel(ensDim);

for v = 1:numel(cv)
    var = obj.var( cv(v) );

    % Preallocate ensemble indices for unremoved draws. Also the sequence
    % elements in each dimension and the size of each sequence
    notnan = ~isnan( subDraws(:,1) );
    nDraws = sum( notnan );
    ensIndices = NaN( nDraws, nDim );

    seqElements = cell( 1, nDim );
    nEls = NaN( 1, nDim );

    % For each ensemble dimension, get the ensemble indices. Add them to the
    % sequence and mean indices to get the set of sequence elements.
    for d = 1:nDim
        ensIndices(:,d) = var.indices{ensDim(d)}( subDraws(notnan,d) );

        seq = var.seqDex{ensDim(d)} + var.meanDex{ensDim(d)}';
        seqElements{d} = seq(:);
        nEls(d) = numel(seq);
    end

    % Get sequence subscript indices for N-D. Use them to subscript the
    % sequence elements
    nSeq = prod(nEls);
    subIndices = subdim( (1:nSeq)', nEls );

    subSequences = NaN( nSeq, nDim );
    for d = 1:nDim
        subSequences(:,d) = seqElements{d}( subIndices(:,d) );
    end

    % Combine the ensemble indices and sequence elements to get the set of
    % indices from which data is read from the grid files.
    subSequences = repmat( subSequences, [nDraws, 1] );
    ensIndices = repmat( ensIndices(:)', [nSeq, 1] );
    ensIndices = reshape( ensIndices, [nSeq*nDraws, nDim] );
    dataIndex = ensIndices + subSequences;
    
    % Get the indices of repeated / overlapping sampling indices. Overwrite
    % overlapping draws with NaN and move to the end of the array.
    [~, uniqIndex] = unique( dataIndex, 'rows', 'stable' );
    overlap = (1:size(dataIndex,1))';
    overlap = overlap( ~ismember(overlap, uniqIndex) );

    badDraw = unique( ceil( overlap / nSeq ) );
    subDraws( badDraw, : ) = NaN;

    failed = ismember( 1:size(subDraws,1), badDraw );
    subDraws = [ subDraws(~failed,:); subDraws(failed,:) ];
end

end