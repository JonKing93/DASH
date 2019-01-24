function[] = reviewIndices( var )

for d = 1:numel(var.dimID)
    checkIndices( var, d, var.indices{d} );
    checkIndices( var, d, var.seqDex{d}+1 );
    checkIndices( var, d, var.meanDex{d}+1 );
end

end