function[draws] = drawEnsembleMembers( nEns, ensDex, overlap, prevDraws )
%% Draws ensemble members, preventing repeat ensemble members and optionally
% 
% draws = drawEnsembleMembers( nEns, ensDex, overlap )
% Does random draws to get the beginning of the sequence of each ensemble
% member in each dimension. Ensures that all ensemble members are unique.
% Checks ensemble sequences for overlap and redraws if not allowed.
%
% draws = drawEnsembleMembers( nEns, ensDex, overlap, prevDraws )
% Draws ensemble members and ensures that there are no repeated values with
% an existing set of draws. Also blocks overlapping sequences if they are
% not allowed.
%
% ----- Inputs -----
%
% nEns: The number of ensemble members to generate.
%
% ensDex: Indices specifying the elements from which ensemble members may
% be selected.
%
% overlap: Logical true/false specifying whether overlapping sequences are
% permitted (true), or not allowed (false).
%
% prevDraws: Previous draws that the new draws should not repeat (or
%       overlap).

% Preallocate the draws
nDim = numel( fixed );
draws = NaN( nEns, nDim );

% Get any prior draws
if ~exist( 'prevDraws', 'var' )
    prevDraws = [];
    nPrev = 0;
else
    nPrev = size( prevDraws, 1 );
end

% Append the new draws to the existing draws
draws = [prevDraws; draws];

% Initialize the redraw indices as all the new draws
redraw = false( size(draw,1) );
redraw( nPrev+1:end ) = true;

% Set a timeout counter for the while loop
runLoop = 2000;

% Draw ensemble members until they meet requirements
while any(redraw)
    
    % Timeout error
    if ~runLoop
        error('Could not select sufficient non-repeated ensemble members in allotted time.');
    end
    runLoop = runLoop-1;
    
    % Get the number of draws to select
    nNew = sum(redraw);
    
    % Delete the repeat draws
    draws(redraw,:) = [];
    
    % Draw new ensemble members and place at the end of the set of draws
    for d = 1:nDim
        if ~fixed(d)
            draws(end+1:end+nNew,d) = randsample( ensDex{d}, nNew, 'replace' );
        end
    end
    
    % Get indices of any repeated draws
    redraw = isrepeat( draws(:,~fixed), 'rows' );

    % Prevent overlap if required
    if ~overlap
        isOverlap = checkOverlap( draws, var.fixed, var.seqDex );
        redraw = redraw & isOverlap;
    end
end

% Once finished, unappend the new draws from the old draws
draws = draws(nPrev+1:end,:);

end