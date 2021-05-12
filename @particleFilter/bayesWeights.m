function[weights] = bayesWeights(sse)
%% Returns particle filter weights using a Bayesian weighting of each particle
%
% weights = particleFilter.bayesWeights(sse)
%
% ----- Inputs -----
%
% sse: Sum of squared errors from a particle filter
%
% ----- Outputs -----
%
% weights: Weights for a particle filter

% Compute normalized values using the log sum of exponentials
sse = (-1/2) * sse;
m = max(sse, [], 1);
lse = m + log( sum( exp(sse-m), 1) );
weights = exp(sse - lse);

% Note on numerical stability:
% 
% Computing
% Y = log( e^X1 + e^X2 + ... e^Xn )
% is numerically unstable because e^(very positive) evaluates to Inf,
% while e^(very negative) evaluates to 0.
%
% However, the alternative formulation:
% Y = m + log( e^(X1-m) + e^(X2-m) + ... )
% is more stable because the magnitude of the exponents is reduced.
%
% Also note that by choosing m as max(X), the largest exponent (X-m) is 0
% and evaluated exactly.

end
