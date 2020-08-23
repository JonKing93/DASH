function[obj] = saveDraws( obj, cv, subDraws, undrawn )
% Save the draws for each set of coupled variables.

% Get the ensemble dimensions
var1 = obj.var( cv(1) );
ensDim = find( ~var1.isState );

% Save the values
for v = 1:numel(cv)
    obj.var( cv(v) ).drawDex = subDraws;
    obj.var( cv(v) ).undrawn = undrawn;
    obj.var( cv(v) ).drawDim = ensDim;
end

end