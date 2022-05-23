function[Xmean, Xdeviations] = decompose(X, dim)
%% dash.math.decompose  Decompose an ensemble into mean and deviations
% ----------
%   [Xmean, Xdeviations] = dash.math.decompose(X)
%   Calculates the mean across an ensemble, and also returns the deviation
%   of each ensemble member from the mean. Acts along the second dimension
%   of the input array. Includes NaN values in all means.
%
%   ... = dash.match.decompose(X, dim)
%   Indicate which dimension is the ensemble dimension. The mean and
%   deviations will be calculated across this dimension. If not specified,
%   acts along the second dimension.
% ----------
%   Inputs:
%       X (numeric array, [? x nMembers x ?]): The ensemble
%           that should be decomposed. An N-dimensional numeric array.
%
%   Outputs:
%       Xmean (numeric array [? x 1 x ?]): The mean of the ensemble.
%           A numeric array. The ensemble dimension of the input X will
%           have a length of 1 in the output Xmean.
%       Xdeviations (numeric array [? x nMembers x ?]): The deviations of
%           each ensemble member from the ensemble mean. Has the same size
%           as the input X. The sum of the deviations across the ensemble
%           dimension will be 0.
%
% <a href="matlab:dash.doc('dash.math.decompose')">Documentation Page</a>

% Default
if ~exist('dim','var') || isempty(dim)
    dim = 2;
end

% Ensemble mean
Xmean = mean(X, dim);

% Only return deviations if requested
if nargout > 1
    Xdeviations = X - Xmean;
end

end