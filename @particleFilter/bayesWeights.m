function[weights] = bayesWeights(sse)
%% particleFilter.bayesWeights  Returns particle filter weights using a Bayesian weighting of each particle
% ----------
%   weights = particleFilter.bayesWeights(sse)
%   Given the sum of squared errors from a particle filter, uses Bayes's
%   formula to compute weights for each particle. The weights will sum to 1
%   in each time step.
%
%   Computes Bayesian weights using the log sum of exponentials, which is
%   more numberically stable than solving Bayes formula directly. Note
%   that when solving Bayes's formula directly, the term:
%       Y = log( e^X1 + e^X2 + ... e^Xn )
%   is numerically unstable because e^(very positive) evaluates to Inf,
%   while e^(very negative) evaluates to 0 because of numerical precision
%   errors.
%
%   However, the alternative formulation:
%       Y = m + log( e^(X1-m) + e^(X2-m) + ... )
%   is more stable because the magnitude of the exponents is reduced. Note
%   that by choosing m as max(X), the largest exponent (X-m) becomes 0, and
%   the term with the largest exponent is evaluated exactly as 1.
% ----------
%   Inputs:
%       sse (numeric matrix [nMembers x nTime]): The sum of squared errors
%           from a particle filter.
%
%   Outputs:
%       weights (numeric matrix [nMembers x nTime]): Weights for each
%           particle in each time step.
%
% <a href="matlab:dash.doc('particleFilter.bayesWeights')">Documentation Page</a>

% Determine the maximum exponent for Bayes formula
sse = (-1/2) * sse;
m = max(sse, [], 1);

% Compute weights using the log sum of exponentials
lse = m + log( sum( exp(sse-m), 1) );
weights = exp(sse - lse);

end