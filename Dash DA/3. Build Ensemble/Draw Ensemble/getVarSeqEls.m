function[seqEls] = getVarSeqEls( var, dimDex )

% Get an index for all sequence elements
[allEls, seqSize] = getAllCombIndex( var.seqDex(dimDex) );

% Subscript to ensemble dimensions
elDex = subdim( seqSize, allEls );

% Preallocate sequence elements
nDim = numel(dimDex);
nSeq = size(elDex,1);
seqEls = NaN( nSeq, nDim );

% For each dimension
for d = 1:nDim
    
    % Get sequence and mean indices
    seq = (var.seqDex{dimDex(d)})';
    mean = var.meanDex{dimDex(d)};
    
    % Generate the full set of sequence elements
    dimSeqEls = seq + mean;
    dimSeqEls = dimSeqEls(:);
    
    % Add to array of sequence elements
    seqEls(:,d) = dimSeqEls( elDex(:,d) );
end

end
