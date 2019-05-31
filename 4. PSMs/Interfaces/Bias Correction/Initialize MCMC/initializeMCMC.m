% Initialize the markov chain monte carlo

% Box-Cox parameter
lambda = 0.2;

% Estimate m from the mean of the original data
m = mean(Y,1);

% Variance
s2 = var(Y, [], 1);

% Correlation coefficients
R = corr( Y, 'rows', 'pairwise' );

% Ensure correlation coefficients are symmetric
R = (R + R')/2;

% Correct R if not positive semi-definite
R = altproj( R );

% Convert R to normal
I = tanh( R ) .^ (-1);



