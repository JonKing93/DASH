%% This gets the size of an arry up to dimension d
function[siz] = fullSize( X, d )

% Get the size
siz = size(X);
nDim = numel(siz);
siz(nDim+1:d) = 1;

end