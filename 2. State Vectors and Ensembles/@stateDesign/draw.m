function[subDraws, undrawn] = draw( ~, nDraws, subDraws, undrawn, random, ensSize )
% Make a selection of draws.

% Error if ensemble cannot complete
if nDraws > numel(undrawn)
    error('Cannot find enough ensemble members. Try using a smaller ensemble.');
end

% Draw in a random or ordered method
if random
    drawIndex = randperm( numel(undrawn), nDraws );
else 
    drawIndex = 1:nDraws;
end
draws = undrawn(drawIndex);
undrawn( drawIndex ) = [];

% Add to the end of the draws array
subDraws( end-nDraws+1:end, : ) = subdim( draws, ensSize );    

end
