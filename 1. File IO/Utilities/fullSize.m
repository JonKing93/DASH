function[siz] = fullSize( X, d )
%% This gets the size of an array through a minumum number of dimensions.
%
% siz = fullSize( X, d )
% Gets the size of array X through a minimum of d dimensions.
% 
% ----- Inputs -----
%
% X: The array
%
% d: The minimum number of dimensions.
%
% ----- Outputs -----
%
% siz: The size of the array.

% Get the size
siz = size(X);
nDim = numel(siz);
siz(nDim+1:d) = 1;

end