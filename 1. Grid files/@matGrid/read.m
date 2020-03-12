function[X] = read( obj, scs )
%% Reads data from a source grid that is an external .mat file

% Adjust scs and keep for merged dimensions
[fullscs, keep] = obj.unmergeSCS( scs );

% Read the data
nDim = size(fullscs,2);
loadIndex = cell(nDim,1);
for d = 1:nDim
    loadIndex{d} = scsIndices( fullscs(:,d) );
end
X = obj.m.(obj.varName)( loadIndex{:} );

% Merge dimensions. Only keep desired indices
X = obj.mergeDims( X, obj.merge );
X = X( keep{:} );

end