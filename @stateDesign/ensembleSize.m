function[siz] = ensembleSize( obj )
nEns = size( obj.var(1).drawDex, 1 );
varLimit = obj.varIndices;
nState = varLimit(end);
siz = [nState, nEns];
end