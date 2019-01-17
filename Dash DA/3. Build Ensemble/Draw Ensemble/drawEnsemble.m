function[sampDex, dimID] = drawEnsemble( coupVars, nEns, overlap )
%% Draws the ensemble indices for a set of coupled variables.

% Get the ensemble dimensions
ensDim = find( ~coupVars(1).isState );
dimID = coupVars(1).dimID(ensDim);
nDim = numel(ensDim);

% Get the set of all possible draws
[allDraws, ensSize] = getAllCombIndex( coupVars(1).indices(ensDim) );

% Get the sequence elements
if ~overlap
    seqEls = getAllSequenceEls( coupVars, dimID );
else
    seqEls = zeros(1,nDim);
end

% Preallocate the sampling indices
nSeq = size(seqEls,1);
sampDex = NaN(nSeq*nEns, nDim);

% Initialize the number of draws
nDraw = nEns;

% Initialize while loop toggles
timeOut = 1000;

% Until are the draws are made...
while nDraw > 0
    
    % If the method timed out, ask the user to continue
    timeOut = timeOut-1;
    if timeOut < 0
        userContinueQuery(nEns);
        timeOut = Inf;
    end
    
    % Check that the draws can be made
    if nDraw > numel(allDraws)
        error('Cannot draw %0.f non-overlapping ensemble members. Use a smaller ensemble.',nEns);
    end
    
    % Make random draws from the ensemble members
    newDraws = randsample( allDraws, nDraw );
    
    % Subscript to ensemble dimensions
    subDraws = subdim( ensSize, newDraws );

    % Get sequence elements for each draw
    currSeq = repmat( seqEls, [nDraw,1]);
    currDraw = reshape(  repmat(subDraws(:)', [nSeq,1]), [nSeq*nDraw, nDim] );
    
    % Get the sample indices
    sampDex( (end - nDraw*nSeq + 1):end, : ) = currSeq + currDraw;
    
    % Erase repeat indices with NaN and move to the end of the sampling indices
    sampDex = eraseRepeat( sampDex, nSeq );
    
    % Get the number of remaining draws
    nDraw = sum(isnan(sampDex(:,1))) / nSeq;
    
    % Remove the current draws from the set of possible future draws
    [~,drawn] = ismember(newDraws, allDraws);
    allDraws(drawn) = []; 
end

% Only return the sequence reference indices
sampDex = sampDex(1:nSeq:end,:) - seqEls(1,:);
    
end   