function[siz] = fullSize( siz, d )
%% This gets the size of an array through a minumum number of dimensions.
%
% siz = fullSize( siz, d )
% Pads a size vector with trailing singletons through a minimum of d dimensions.
% 
% ----- Inputs -----
%
% siz: A size vector
%
% d: The minimum number of dimensions.
%
% ----- Outputs -----
%
% siz: The size of the array.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the size
nDim = numel(siz);
siz(nDim+1:d) = 1;

end