function[variance, metric] = update(obj)
%% optimalSensor.update  Updates the metric's deviations using the proxy estimates
% ----------
%   [variance, metric] = <strong>obj.update</strong>
%   Uses the proxy estimates and uncertainties to update the metric.
%   Returns the final variance of the metric, as well as the final metric
%   metric itself. If the uncertainties are covariances, uses the full R 
%   uncertainty covariance to compute the update. Otherwise, uses the
%   provided R variances to implement a diagonal covariance matrix.
%
%   The method proceeds by using a standard ensemble square root Kalman
%   filter to update the ensemble deviations of the metric.
% 
%   **Important**
%   Note that this method accounts for the covariance between the
%   observation sites when updating the ensemble deviations. Thus, the
%   final variance correctly reflects the variance reduction that results
%   from assimilating a network with multiple observation sites.
% ----------
%   Outputs:
%       variance (numeric scalar): The variance of the metric after the
%           update has been applied.
%       metric (numeric vector [nMembers]): The metric after the update has
%           been applied. Note that the method only updates the metric's
%           ensemble deviations. The ensemble mean of the metric is
%           unaffected.
%
% <a href="matlab:dash.doc('optimalSensor.update')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:update";
dash.assert.scalarObj(obj, header);

% Require essential data inputs
obj.assertFinalized("updating the metric's ensemble deviations", header);

% Coefficient for unbiased estimator
unbias = dash.math.unbias(obj.nMembers);

% Decompose the metric and estimates. Get the Y covariances
[Jmean, Jdev] = dash.math.decompose(obj.J);
[~, Ydev] = dash.math.decompose(obj.Ye);
Ycov = dash.math.covariance(Ydev, Ydev, unbias);

% Get the R covariance
if obj.Rtype == 0
    Rcov = diag(obj.R);
else
    Rcov = obj.R;
end

% Get the adjusted Kalman gain
Knum = dash.math.covariance(Jdev, Ydev, unbias);
Kdenom = dash.kalman.denominator(Ycov, Rcov);
Ka = dash.kalman.adjusted(Knum, Kdenom, Rcov);

% Update the metric and assess final variance
Jdev = dash.kalman.updateDeviations(Jdev, Ka, Ydev);
metric = Jmean + Jdev;
variance = dash.math.variance(Jdev, unbias);

end