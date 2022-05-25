function[variance, metric] = evaluate(obj)
%% optimalSensor.evaluate  Evaluates the variance reduced by individual proxies in a network
% ----------
%   [variance, metric] = obj.evaluate
%   For each observation site, evaluates the amount of the metric's
%   variance that is reduced when the site is assimilated alone. Evaluates
%   the *individual* influence of proxy observations on an assimilation.
%   
%   **Important**
%   This method neglects the covariance between observation sites, and only
%   considers the effects of assimilating site individually. In general,
%   when observation estimates covary, their total effect on the metric's
%   variance will be smaller than the sum of their individual effects. Use
%   the "optimalSensor.update" method to assess the total effect on metric
%   variance when multiple estimates covary. Also note that we are *not*
%   referring to R uncertainty covariances here. This effect still occurs
%   when using R uncertainty variances.
% ----------
%   Outputs:
%       variance (scalar struct): Reports the variance of the metric across
%           the ensemble. Has the following fields.
%           .initial (numeric scalar): The initial variance of the metric
%           .delta (numeric vector [nSites]): Reports the reduction of
%               variance that occurs when assimilating each site individually
%       metric (scalar struct): Reports the metric. Has the fields:
%           .initial (numeric vector [nMembers]): The initial metric
%               extracted from the prior.
%   
% <a href="matlab:dash.doc('optimalSensor.evalute')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:evaluate";
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

% Get R variances
R = obj.Rvariances;

% Decompose the estimates and get their effect on variance
[~, Ydev] = dash.math.decompose(obj.Ye);
variance.delta = obj.varianceReduction(Jdev, Ydev, R, unbias);

end