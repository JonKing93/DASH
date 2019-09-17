function[overlap, ensSize, undrawn, subDraws] = initializeDraws( obj, cv, nDraws )
% Create the initial array of subscripted draws, and undrawn values and
% some other values

% Get the overlap and ensemble size information
var1 = obj.var( cv(1) );
overlap = obj.allowOverlap( cv(1) );

ensDim = find( ~var1.isState );
nDim = numel(ensDim);

ensSize = NaN( 1, nDim );
for d = 1:nDim
    ensSize(d) = numel( var1.indices{ ensDim(d) } );
end

% Preallocate the draw arrays
if obj.new
    undrawn = (1:prod(ensSize))';
    subDraws = NaN( nDraws, nDim );
else
    undrawn = var1.undrawn;
    subDraws = [var1.drawDex; NaN(nDraws, nDim)];
end

end