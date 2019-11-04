function[X, m] = read( obj, scs, ~, passVal )
%% Reads data from a source grid that is an external .mat file

% Either load matfile object or use previous
if ~isempty( passVal )
    m = passVal;
else
    m = matfile( obj.filepath );
end

% Read the data
nDim = size(scs,2);
loadIndex = cell(nDim,1);
for d = 1:nDim
    loadIndex{d} = scs(1,d) : scs(3,d) : scs(1,d)+scs(3,d)*(scs(2,d)-1);
end
X = m.(obj.varName)( loadIndex{:} );

end