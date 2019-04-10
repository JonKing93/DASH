function[seqEls] = getVarSeqEls( var, ensDex )
%% Get the sequence elements for a variable
%
% var: varDesign
%
% ensDex: Dimensional index for all ensemble dimensions
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get an index for all sequence elements
[allEls, seqSize] = getAllCombIndex( var.seqDex(ensDex) );

% Subscript to ensemble dimensions
elDex = subdim( seqSize, allEls );

% Preallocate sequence elements
nDim = numel(ensDex);
nSeq = size(elDex,1);
seqEls = NaN( nSeq, nDim );

% For each dimension
for d = 1:nDim
    
    % Get sequence and mean indices
    seq = (var.seqDex{ensDex(d)})';
    mean = var.meanDex{ensDex(d)};
    
    % Generate the full set of sequence elements
    dimSeqEls = seq + mean;
    dimSeqEls = dimSeqEls(:);
    
    % Add to array of sequence elements
    seqEls(:,d) = dimSeqEls( elDex(:,d) );
end

end
