function[siz] = ensembleSize( obj )
% Gets the size of the ensemble associated with the design
nEns = size( obj.var(1).drawDex, 1 );
varLimit = obj.varIndices;
nState = varLimit(end);
siz = [nState, nEns];
end