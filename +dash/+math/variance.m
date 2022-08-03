function[Xvar] = variance(Xdev, unbias)
%% dash.math.variance  Computes variance from the deviations of an ensemble
% ----------
%   Xvar = dash.math.variance(Xdev)
%   Returns the variance across an ensemble given the ensemble's
%   deviations. Determines the coefficient of unbiased estimation using the
%   number of members in the ensemble.
%
%   Xvar = dash.math.variance(Xdev, unbias)
%   Uses a pre-determined coefficient of unbiased estimation.
% ----------
%   Inputs:
%       Xdev (numeric matrix [N x nMembers]): A set of ensemble deviations.
%           The ensemble members should be organized along the second
%           dimension.
%       unbias (numeric scalar): A pre-determined coefficient of unbiased
%           estimation
%
%   Outputs:
%       Xvar (numeric vector [N]): The variances across the ensemble
%
% <a href="matlab:dash.doc('dash.math.unbias')">Documentation Page</a>

% Coefficient of unbiased estimation
if ~exist('unbias','var') || isempty(unbias)
    nMembers = size(Xdev,2);
    unbias = dash.math.unbias(nMembers);
end

% Variance is the sum of squared deviations
Xvar = unbias * sum(Xdev.^2, 2);

end

