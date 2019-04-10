function[meta] = indexMetadata( meta, index )
%% Samples n-dimensional metadata from the indexed rows

metaDex = repmat( {':'}, [1, ndims(meta)] );
metaDex{1} = index;
meta = meta( metaDex{:} );

end