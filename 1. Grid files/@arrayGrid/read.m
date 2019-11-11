function[X, m] = read(obj, scs, gridpath, passVal )
%% Read data from an array saved locally to a .grid file.

nDim = size(scs,2);
loadIndex = cell(nDim,1);
for d = 1:nDim
    loadIndex{d} = scs(1,d): scs(3,d) : scs(1,d)+scs(3,d)*(scs(2,d)-1);
end

if ~isempty( passVal )
    m = passVal;
else
    m = matfile( gridpath );
end

X = m.(obj.dataName)( loadIndex{:} );

end




    
