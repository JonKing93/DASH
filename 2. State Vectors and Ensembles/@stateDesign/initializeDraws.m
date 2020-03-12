function[overlap, ensSize, undrawn, subDraws] = initializeDraws( obj, cv, nDraws )
% Initialize a set of new draws

% Get the overlap and ensemble size information
var1 = obj.var( cv(1) );
overlap = obj.allowOverlap( cv(1) );

ensDim = find( ~var1.isState );
nEnsDim = numel(ensDim);

ensSize = NaN( 1, nEnsDim );
for d = 1:nEnsDim
    ensSize(d) = numel( var1.indices{ ensDim(d) } );
end

% Preallocate the draw arrays
if obj.new
    undrawn = (1:prod(ensSize))';
    subDraws = NaN( nDraws, nEnsDim );
else
    undrawn = var1.undrawn;
    subDraws = [var1.drawDex; NaN(nDraws, nEnsDim)];
end

end