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

end
