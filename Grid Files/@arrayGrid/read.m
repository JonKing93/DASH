function[X] = read(obj, start, count, stride, gridpath )
%% Read data from an array saved locally to a .grid file.

nDim = length(start);
loadIndex = cell(nDim,1);
for d = 1:nDim
    loadIndex{d} = start(d) : stride(d) : start(d)+stride(d)*(count(d)-1);
end

m = matfile( gridpath );
X = m.(obj.dataName)( loadIndex{:} );

end




    
