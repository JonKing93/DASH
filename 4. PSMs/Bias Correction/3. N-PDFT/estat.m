function[E] = estat( x, y )
%% Computes the E-statistic for two vectors
%
% E = estat(x, y)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
%
% ----- References -----
% Rizzo, M. L., & Székely, G. J. (2016). Energy distance. Wiley 
% Interdisciplinary Reviews: Computational Statistics, 8(1), 27-38.

% Check for same number of dimensions
if ~ismatrix(x) || ~ismatrix(y)
    error('X and Y must be matrices');
elseif size(x,2) ~= size(x,2)
    error('x and y must have the same number of columns.');
end

% Get the number of samples in each distribution
n = size(x,1);
m = size(y,1);

% Get the pairwise distance terms
A = (1/(n*m)) * pairdist(x,y);
B = (1/n^2) * pairdist(x,x);
C = (1/m^2) * pairdist(y,y);

% Compute the E statistic
E = 2*A - B - C;

end

function[dist] = pairdist(x,y)
% Computes the average pairwise distance between two vectors

% Swap x and y so that x has fewer rows
if size(x,1) > size(y,1)
    swap = x;
    x = y;
    y = swap;
end

% Initialize the sum distance
dist = 0;

% For each row of x
for k = 1:size(x,1)
    
    % Get the distance with each row of y
    dist = dist + sum( sqrt( sum( (x(k,:)-y).^2, 2 ) ) );
end

end 