function[obj] = makeDraws( obj, cv, nEns, random )
% Select a set of ensemble draws

% Initialize values in preparation for making draws. Note if there are
% previous draws and add to them.
nDraws = nEns;
[overlap, ensSize, undrawn, subDraws] = obj.initializeDraws( cv, nDraws );

% Make draws. Remove overlapping draws if necessary. Continue until
% the ensemble is complete or impossible.
while nDraws > 0
    [subDraws, undrawn] = obj.draw( nDraws, subDraws, undrawn, random, ensSize );

    if ~overlap
        [subDraws] = obj.removeOverlap( subDraws, cv );
        nDraws = sum( isnan( subDraws(:,1) ) );
    end
end

% Save the draws for each variable
obj = obj.saveDraws( cv, subDraws, undrawn );

end