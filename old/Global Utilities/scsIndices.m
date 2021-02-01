function[index] = scsIndices( scs )
% Get the indices associated with start, count, stride
%
% index = scsIndices( scs )
if numel(scs)~=3
    error('scs must have 3 elements.');
end
index = scs(1) : scs(3) : scs(1)+scs(3)*(scs(2)-1);
end
