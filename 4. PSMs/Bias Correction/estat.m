function[E] = estat( x, y )
%% Computes the E-statistic for two vectors

% Check for same number of dimensions
if ~ismatrix(x) || ~ismatrix(y)
    error('X and Y must be matrices');
elseif size(x,2) ~= size(x,2)
    error('x and y must have the same number of columns.');
end

% Get the pairwise distance terms
A = pairdist(x,y);
B = pairdist(x,x);
C = pairdist(y,y);

% Compute the E statistic
E = 2*A - B - C;

end

function[dist] = pairdist(x,y)
% Computes the average pairwise distance between two vectors

% Get the number of samples in each distribution
[n, nVar] = size(x);
m = size(y,1);

% Vectorize the calculation
x = repmat( x', [m,1]);
x = reshape(x, [nVar, n*m])';
y = repmat(y, [n, 1]);

% Compute the distance between every pair of samples. This is the 2-norm
% (Euclidean distance) between each row of the vectorized matrices.
dist = sqrt( sum( (x-y).^2, 2) );

% Get the total distance component
dist = sum(dist);

end 