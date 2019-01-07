% Determine the number of elements in the state vector
nFixed = [46,92,1,NaN,NaN];
% But we're going to be taking a product, so we can use 1 as the identity for the NaN values
 nFixed = [46, 92, 1, 1, 1];

% Then we can add them to any that have nexts
nNext = [0,0,0,2,0]
nSize = nFixed + nNext;

% And this product should give the number of elements
N = prod(nSize);