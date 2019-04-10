function[sampDex, badDraw] = removeOverlappingDraws( sampDex, nSeq )

% Get the indices of repeated sampling indices
[~, notrepeat] = unique( sampDex, 'rows', 'stable' );
repDex = (1:size(sampDex,1))';
repDex = repDex( ~ismember(repDex, notrepeat) );
        
% Get the full set of sampling indices associated with the ensemble
% indices that overlap previous draws.
badDraw = unique( ceil( repDex / nSeq ) );
delete = (badDraw - 1)*nSeq + (1:nSeq);
delete = delete(:);

% Replace any bad draws (and all associated sampling indices) with NaN
sampDex( delete, : ) = NaN;

% Any draws not removed were successful. When we check for repeats,
% we work from the first sampling index to the last. We want to
% ensure that these successful draws are preserved in the case of
% overlap with additional draws. So we want to move the (NaN)
% points associated with the bad draws to the end of the sampling
% index array.

% Convert deletion indices to logical index
delete = ismember(( 1:size(sampDex,1))', delete );

% Move unfilled draws to the end
sampDex = [sampDex(~delete,:); sampDex(delete,:)];

end