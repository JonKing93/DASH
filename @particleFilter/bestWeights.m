function[weights] = bestWeights(sse, N)
%% Returns particle weights for an average of the best N particles
%
% weights = particleFilter.bestWeights(sse, N)
%
% ----- Inputs -----
%
% sse: Sum of squared errors from a particle filter
%
% N: The number of the particles to use in the average
%
% ----- Outputs -----
%
% weights: Weights for a particle filter

% Find the best particles
[nEns, nTime] = size(sse);
weights = zeros(nEns, nTime);
[~, rank] = sort(sse, 1);
best = ismember(rank, 1:N);

% Apply equal weights to each of the best particles
weights(best) = 1/N;

end