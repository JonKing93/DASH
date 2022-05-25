function[variance, metric] = update(obj)
%% optimalSensor.update  Updates the metric's deviations using the proxy estimates
% ----------
%   [variance, metric] = obj.update
%   Uses the proxy estimates and uncertainties to update the metric.
%   Returns the initial and final variance of the metric, as well as the
%   initial and final metric itself. If the uncertainties are covariances,
%   uses the full R uncertainty covariance to compute the update. Otherwise,
%   uses the provided R variances.
% ----------
%   Outputs
%       variance (scalar struct): Reports the variance of the metric. Has
%           the following fields:
%           .initial (numeric scalar): The initial variance of the metric
%           .final (numeric scalar): The variance of the metric after the update
%       metric (scalar struct): Reports the metric itself. Has the
%           following fields:
%           .initial (numeric vector [nMembers]): The initial metric
%               extracted from the prior
%           .final (numeric vector [nMembers]): The final metric after the
%               update. Note that the method only updates the metric's
%               deviations. The metric mean is unaffected.
%
% <a href="matlab:dash.doc('optimalSensor.update')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:update";
dash.assert.scalarObj(obj, header);

% Require essential data inputs
obj.assertFinalized;

% Initialize outputs
variance = struct;
metric = struct;

% Coefficient for unbiased estimator
unbias = 1 / (obj.nMembers - 1);

% Get the metric, its deviations, and its variance
J = obj.computeMetric;
[~, Jdev] = dash.math.decompose(J);
Jvar = unbias * sum(Jdev.^2, 2);

metric.initial = J;
variance.initial = Jvar;

% Get the deviations for the prior and the estimates
[Xmean, Xdev] = dash.math.decompose(obj.X);
[~, Ydev] = dash.math.decompose(obj.Ye);

% Get R covariance
R = obj.R;
if Rtype == 0
    R = diag(R);
end

% Update the deviations for the prior
Knum = unbias .* (Xdev * Ydev');
Kdenom = unbias .* (Ydev * Ydev') + R;
K = Knum / Kdenom;
a = 1 / (1 + sqrt(R / Kdenom));
Xdev = Xdev - a * K * Ydev;
X = Xmean + Xdev;

% Compute the updated metric and variance
J = obj.computeMetric(X);
[~, Jdev] = dash.math.decompose(J);
Jvar = unbias * sum(Jdev.^2, 2);

metric.final = J;
variance.final = Jvar;

end