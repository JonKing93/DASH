function[siz] = ensembleSize( obj )
ensDim1 = find( ~obj.var(1).isState, 1 );
nEns = numel( obj.var(1).drawDex{ensDim1} );
varLimit = obj.varIndices;
nState = varLimit(end);
siz = [nState, nEns];
end