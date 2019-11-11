function[output] = pf( M, D, R, F, N )
%% Implements a particle filter.
%
% [output] = dash.pf( M, D, R, F, N )
%
% ----- Inputs -----
%
% M: An ensemble (nState x nEns)
%
% D: Observations (nObs x nTime)
%
% R: Observation Uncertainty (nObs x nTime)
%
% F: A cell vector of PSM objects (nObs x 1)
%
% N: The number of particles to use when calculating the ensemble mean. A
%    positive scalar. Use NaN for probabilistic weights.
%
% ----- Outputs -----
%
% output: A structure with the following fields
%
%   settings - Settings used to run the analysis
%
%   A - The updated ensemble mean (nState x nTime)
%
%   sse - The sum of squared errors for each particle (nEns x nTime)
%
%   weights - The weights used to compute the updated ensemble mean

% Preallocate
[nObs, nTime] = size(D);
nEns = size(M,2);
Ye = NaN( nObs, nEns );

% Run the forward models. Get Ye and R
for d = 1:nObs
    hasObs = ~isnan( D(d,:) );
    [Ye(d,:), R(d,hasObs)] = dash.processYeR( F{d}, M(F{d}.H,:), R(d,hasObs), NaN, d );
end

% Permute for singleton expansions
D = permute(D, [1 3 2]);
R = permute(R, [1 3 2]);

% Sum of uncertainty weighted squared errors. Use to compute weights and update.
sse = squeeze( sum(  (1./R) .* (D - Ye).^2,  1 ) );
weights = dash.pfWeights( sse, N );
A = M * weights;

% Build the output structure
output.settings = struct('Analysis','Particle Filter','Weights', 'Probabilistic');
if ~isnan(N)
    output.settings.Weights = 'Best N';
    output.settings.N = N;
end
output.A = A;
output.sse = sse;
output.weights = weights;

end