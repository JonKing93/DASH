function[weights, sse] = computeWeights(obj)
%% particleFilter.computeWeights  Return the weights for a particle filter
% ----------
%   weights = <strong>obj.computeWeights</strong>
%   Computes particle filter weights for an assimilation. Requires the
%   particle filter object to have observations, estimates, and 
%   uncertainties. Does not require a prior.
%
%   [weights, sse] = <strong>obj.computeWeights</strong>
%   Also returns the sum of squared errors for each particle.
% ----------
%   Outputs:
%       weights (numeric matrix [nMembers x nTime]): The weights for a
%           particle filter. Each row holds the weights for a particular
%           ensemble member. Each column holds weights for an assimilated
%           time step. The weights are used to implement a weighted mean of
%           the particles in each assimilation time step.
%       sse (numeric matrix [nMembers x nTime]): The SSE values for a
%           particle filter. Each row holds the weights for a particular
%           ensemble member. Each column holds weights for an assimilation
%           time step. Lower values indicate greater similarity to the proxy
%           observations.       
%
% <a href="matlab:dash.doc('particleFilter.computeWeights')">Documentation Page</a>

% Setup
header = "DASH:particleFilter:computeWeights";
dash.assert.scalarObj(obj, header);

% Require observations, estimates, uncertainties (but not prior)
if ~obj.isfinalized
    obj = obj.finalize(false, 'computing particle weights', header);
end

% Compute the sum of squared errors
sse = obj.sse;

% Calculate weights using the appropriate weighting scheme
if obj.weightType == 0
    method = 'bayesWeights';
elseif obj.weightType == 1
    method = 'bestNWeights';
end
weights = particleFilter.(method)(sse, obj.weightArgs{:});

end