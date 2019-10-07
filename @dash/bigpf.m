function[output] = bigpf( ens, D, R, F, N, batchSize )
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
% batchSize: The number of ensemble members to load per step.
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
nEns = ens.ensSize(2);
nState = ens.ensSize(1);

Ye = NaN( nObs, nEns );
A = zeros( nState, nTime );
sse = NaN( nEns, nTime );

% Get the number of batches
nBatch = floor( ens.ensSize(2) / batchSize );
if mod( ens.ensSize(2), batchSize ) ~= 0
    nBatch = nBatch + 1;
end

% Permute for singleton expansion
D = permute(D, [1 3 2]);
R = permute(R, [1 3 2]);

% Load the portion of the ensemble for each batch
for b = 1:nBatch
    batchIndices = (b-1)*blockSize+1 : min( b*blockSize, ens.ensSize(2) );
    M = ens.load( batchIndices );
    
    % Generate Ye and compute sse
    for d = 1:nObs
        Ye(d, batchIndices) = dash.processYeR( F{d}, M(F{d}.H, :), R(d,:), NaN, d );
    end
    sse(batchIndices,:) = squeeze( sum(  (1./R) .* (D - Ye(:,batchIndices)).^2,  1 ) );
end

% Get the weights
weights = dash.pfWeights( sse, N );

% Use the weights to combine each batch
for b = 1:nBatch
    batchIndices = (b-1)*blockSize+1 : min( b*blockSize, ens.ensSize(2) );
    M = ens.load( batchIndices );
    A = A + M * weights( batchIndices, : );
end

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