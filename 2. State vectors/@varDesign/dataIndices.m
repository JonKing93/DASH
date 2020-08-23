function[dataIndex, nSeq] = dataIndices( var, subDraws )
%% Determines all of the grid file indices that will be loaded for a
% variable with a given set of ND subscripted draws

ensDim = find( ~var.isState );
nDim = numel(ensDim);

% Preallocate ensemble indices for draws, sequence elements in each
% dimension, size of the sequence
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

end
