function[sampDex] = getSamplingIndices( ensDex, seqEls )
% Combines a set of subscripted draws and sequence elements into a set of
% sampling indices

% Get the number of draws, sequence elements, and ensemble dimensions
[nDraws, nDim] = size(ensDex);
nSeq = size(seqEls,1);

% Replicate the sequence elements over each draw
seqEls = repmat( seqEls, [nDraws,1] );

% Replicate the draws over each sequence element
ensEls = repmat( ensDex(:)', [nSeq,1] );
ensEls = reshape( ensEls, [nSeq*nDraws, nDim] );

% Add together to get the full set of sampling indices
sampDex = ensEls + seqEls;

end



