function[subDraws] = removeOverlappingDraws( var, subDraws, ensID )

% Get the subdraws that are not NaN
notnan = ~isnan( subDraws(:,1) );

% Preallocate the ensemble indices associated with the draws
ensDex = NaN( size(subDraws(notnan,:)) );

% Preallocate sequence elements and the number of sequence elements
% for each ensemble dimension
nDim = numel(ensID);
seqEls = cell( 1, nDim );
nEls = NaN( 1, nDim );

% For each ensemble dimension
for dim = 1:nDim
    
    % Get the index of the dimension in the variable
    d = checkVarDim( var, ensID(dim) );
    
    % Get the ensemble indices
    ensDex(:,dim) = var.indices{d}( subDraws(notnan,dim) );
    
    % Add the sequence and mean indices to get the full set of sequence
    % elements for this dimension
    seq = var.seqDex{d} + var.meanDex{d}';
    seq = seq(:);
    
    % Record the sequence elements
    seqEls{dim} = seq;
    nEls(dim) = numel(seq);
end

% Get sequence subscript indices for N-D
nSeq = prod(nEls);
subDex = subdim( nEls, (1:nSeq)' );

% Get the subscripted sequence elements
subSeq = NaN( nSeq, nDim );
for dim = 1:numel(ensID)
    subSeq(:,dim) = seqEls{dim}( subDex(:,dim) );
end

% Combine the ensemble indices and sequence elements to get the full set of
% sampling indices
sampDex = getSamplingIndices( ensDex, seqEls );

% Get the indices of repeated sampling indices
[~, notrepeat] = unique( sampDex, 'rows', 'stable' );
repDex = (1:size(sampDex,1))';
repDex = repDex( ~ismember(repDex, notrepeat) );

% Replace the draws associated with overlap with NaN
badDraw = unique( ceil( repDex / nSeq ) );
subDraws( badDraw, : ) = NaN;

% Move failed draws to the end of the array so that new draws don't
% eliminate previously successful draws
failed = ismember( 1:size(subDraws,1), badDraw );
subDraws = [ subDraws(~failed,:), subDraws(failed,:) ];

end