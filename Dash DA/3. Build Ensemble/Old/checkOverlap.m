function[redraw] = checkOverlap( draws, fixed, seqDex )
%% This determines the sequence members for a set of draws

% Get sizes
nDim = numel(fixed);
nDraw = size(draws,1);

% Initialize the interval spacing for each dimensional sequence coordinate
% and the total number of sequence elements.
nInterval = zeros( nDim, 1 );
nSeq = 1;

% For each ensemble dimension
for d = 1:nDim
    if ~fixed(d)
        % Get the interval spacing
        nInterval(d) = nSeq;
        
        % Increase the total number of sequences
        nSeq = nSeq * numel(seqDex{d});
    end
end

% Preallocate the sequence coordinates
nCoord = nSeq * nDraw;
seqCoord = NaN( nCoord, nDim );

% Get the sequence coordinates
for d = 1:nDim
    if ~fixed(d)
        
        % Build the sequence over all previous sequences
        seq = draws(:,d) + seqDex{d};
        seq = repmat( seq, [nInterval(d),1] );
        seq = seq(:);
        
        % Build over posterior sequences
        nPost = nSeq*nDraw / numel(seq);
        seqCoord(:,d) = repmat( seq, nPost, 1 );
    end
end

% Get a reordering index so that the sequences are listed by draw
reorder = NaN( nCoord, 1 );
allCoord = 1:nCoord;
for d = 1:nDraw
    reorder( (d-1)*nSeq+1 : d*nSeq ) =  allCoord( d:nDraw:end );
end

% Reorder the coordinates
seqCoord = seqCoord(reorder,:);

% Check for repeated values
redraw = isrepeat( seqCoord(:,~fixed), 'rows' );

% Shape by draw
redraw = reshape( redraw, nSeq, nDraw );

% Determine if any draws have overlapping elements
redraw = any( redraw )';

end