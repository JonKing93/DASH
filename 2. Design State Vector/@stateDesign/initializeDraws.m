function[overlap, ensSize, undrawn, subDraws] = initializeDraws( obj, cv, nDraws )
% Create the initial array of subscripted draws, and undrawn values and
% some other values

% Get the overlap and ensemble size information
var1 = obj.var( cv(1) );
overlap = var1.overlap;

ensDim = ~var1.isState;
ensSize = var1.dimSize( ensDim );

% Preallocate the draw arrays
nDim = sum(ensDim);
if newEnsemble
    undrawn = (1:prod(ensSize))';
    subDraws = NaN( nDraws, nDim );
else
    undrawn = var1.undrawn;
    subDraws = [var1.drawDex; NaN(nDraws, nDim)];
end

end