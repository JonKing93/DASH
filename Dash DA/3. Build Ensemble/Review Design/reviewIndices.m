function[] = reviewIndices( var )

for d = 1:numel(dimID,var)
    checkIndices( var, d, indices{d} );
    checkIndices( var, d, seqDex{d}+1 );
    checkIndices( var, d, meanDex{d}+1 );
end

end