function[X] = read(obj, scs )
%% Read data from an array saved locally to a .grid file.

nDim = size(scs,2);
loadIndex = cell(nDim,1);
for d = 1:nDim
    loadIndex{d} = scs(1,d): scs(3,d) : scs(1,d)+scs(3,d)*(scs(2,d)-1);
end

X = obj.m.(obj.dataName)( loadIndex{:} );

end




    
