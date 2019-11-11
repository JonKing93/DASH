function[X, m] = read( obj, scs, ~, passVal )
%% Reads data from a source grid that is an external .mat file

% Either load matfile object or use previous
if ~isempty( passVal )
    m = passVal;
else
    m = matfile( obj.filepath );
end

% Adjust scs and keep for merged dimensions
[fullscs, keep] = obj.unmergeSCS( scs );

% Read the data
nDim = size(fullscs,2);
loadIndex = cell(nDim,1);
for d = 1:nDim
    loadIndex{d} = fullscs(1,d) : fullscs(3,d) : fullscs(1,d)+fullscs(3,d)*(fullscs(2,d)-1);
end
X = m.(obj.varName)( loadIndex{:} );

% Merge dimensions. Only keep desired indices
X = obj.mergeDims( X, obj.merge );
X = X( keep{:} );

end