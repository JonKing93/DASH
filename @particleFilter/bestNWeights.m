function[weights] = bestNWeights(sse, N)
%% particleFilter.bestNWeights  Returns particle filter weights that implement an average over the best N particles
% ----------
%   weights = particleFilter.bestNWeights(sse, N)
%   Given the sum of squared errors from a particle filter, determine the N
%   particles with the highest weights. Applies equal weighting to these N
%   particles, and 0 weight to all other particles. The weight for each of
%   the N particles will be 1/N and the sum of all weights will be 1.
% ----------
%   Inputs:
%       sse (numeric matrix [nMembers x nTime]): The sum of squared errors
%           from a particle filter.
%       N (scalar positive integer): The number of best particles that
%           should receive equal, non-zero weights.
%
%   Outputs:
%       weights (numeric matrix [nMembers x nTime]): The weight for each
%           particle in each time step.
%
% <a href="matlab:dash.doc('particleFilter.bestNWeights')">Documentation Page</a>

% Find the best N particles in each time step
[nMembers, nTime] = size(sse);
[~, ii] = sort(sse, 1);
[~, rank] = sort(ii, 1);
best = ismember(rank, 1:N);

% Apply equal weights summing to 1 to each of the best N particles in each
% time step. Use 0 weights for all other particles
weights = zeros(nMembers, nTime);
weights(best) = 1/N;

end