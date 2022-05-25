function[variance, metric] = update(obj)
%% optimalSensor.update  Updates the metric's deviations using the proxy estimates
% ----------
%   [variance, metric] = obj.update
%   Uses the proxy estimates and uncertainties to update the metric.
%   Returns the initial and final variance of the metric, as well as the
%   initial and final metric itself. If the uncertainties are covariances,
%   uses the full R uncertainty covariance to compute the update. Otherwise,
%   uses the provided R variances.
%
%   The method proceeds by using a standard ensemble square root Kalman
%   filter to update the ensemble deviations from the prior. A metric is then
%   computed from the update prior. 
% 
%   **Important**
%   Note that this method accounts for the covariance between the
%   observation sites when updating the ensemble deviations. Thus, the
%   final variance correctly reflects the variance reduction that results
%   from assimilating a network with multiple observation sites.
% ----------
%   Outputs
%       variance (scalar struct): Reports the variance of the metric across
%           the ensemble. Has the following fields:
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
unbias = dash.math.unbias(obj.nMembers);

% Get the metric, its deviations, and its variance
J = obj.computeMetric;
[~, Jdev] = dash.math.decompose(J);
Jvar = dash.math.variance(Jdev, unbias);

metric.initial = J;
variance.initial = Jvar;

% Get the deviations for the prior and the estimates
[Xmean, Xdev] = dash.math.decompose(obj.X);
[~, Ydev] = dash.math.decompose(obj.Ye);

% Get R covariance
R = obj.R;
if obj.Rtype == 0
    R = diag(R);
end

% Update the deviations for the prior
Knum = dash.math.covariance(Xdev, Ydev, unbias);
Kdenom = dash.kalman.denominator(Ydev, R, unbias);
K = Knum / Kdenom;
a = dash.kalman.adjusted(R, Kdenom);
Xdev = dash.kalman.updateDeviations(Xdev, a, K, Ydev);
X = Xmean + Xdev;

% Compute the updated metric and variance
J = obj.computeMetric(X);
[~, Jdev] = dash.math.decompose(J);
Jvar = dash.math.variance(Jdev, unbias);

metric.final = J;
variance.final = Jvar;

end