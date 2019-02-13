function[meta] = indexMetadata( meta, index )
%% Reduces n-dimensional metadata to the indexed rows

metaDex = repmat( {':'}, [1, ndims(meta)] );
metaDex{1} = index;
meta = meta( metaDex{:} );

end