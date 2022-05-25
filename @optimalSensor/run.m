function[optimalSites, variance, metric] = run(obj, N)
%% optimalSensor.run  Runs an optimal sensor
% ----------
%   [optimalSites, variance, metric] = obj.run
%   Runs the optimal sensor algorithm. Sets the number of sensors equal to
%   the number of sites in the object.
%
%   [optimalSites, variance, metric] = obj.run(N)
%   Runs the optimal sensor algorithm for the N best sensors. The number of
%   sensors cannot exceed the number of sites for the object.
%
%   The following is an outline of the optimal sensor algorithm:
%   The method begins by extracting a metric from the prior. It then
%   evaluates the ability of each observation site to reduce the variance
%   of the metric across the ensemble. This evaluation only the considers
%   the reduction of variance that occurs when the site is assimilated
%   alone. The site that is most able to reduce metric variance is deemed
%   the "optimal sensor", and that single site is then used to update the
%   deviations of the prior ensemble. The method then removes the optimal
%   sensor from the observation network, and repeats the analysis using the
%   remaining sites and updated metric. This process iterates until the
%   requested number of sensors have been selected and used to update the
%   metric.
%
%   **Important**
%   Because this method only assimilates a single site at a time, it only
%   considers R uncertainty variances. If observation errors are strongly
%   correlated (such that R uncertainty covariances are required), then
%   this may not be the most suitable method. You can use the
%   "optimalSensor.update" method to evaluate the variance reduced by sets
%   of observations with correlated errors.
%
%   Additionally, the method accounts for covariance between the proxy
%   estimates by updating the estimates via the Kalman Gain. This is
%   most appropriate when using linear (or approximately linear) forward
%   models to generate proxy estimates, but may not be suitable for
%   strongly non-linear forward models. You may want to combine the
%   "optimalSensor.evaluate" command with output from "kalmanFilter.run"
%   and the "PSM.estimate" command if running an optimal sensor for
%   non-linear forward models.
% ----------
%   Inputs:
%       N (scalar positive integer): Indicates the number of optimal
%           sensors to select. Must be a positive integer between 1 and the
%           number of observation sites. If not provided as input, sets N
%           to the number of observation sites.
%
%   Outputs:
%       optimalSites (vector, linear indices [N]): Indicates the optimal
%           observation site for each iteration of the optimal sensor
%           algorithm. Has one element per selected optimal sensor. Each
%           element is the index of the observation site selected as
%           optimal for that iteration. The first element is the first
%           optimal site, the second element is the optimal site after the
%           first site has been used to update the prior and removed from
%           the network, etc.
%       variance (scalar struct): Indicates the variance of the metric
%           across the ensemble. Has the following fields:
%           .initial (numeric scalar): The initial variance of the metric
%           .updated (numeric vector [N]): The variance of the metric after
%               the prior is updated in each algorithm iteration
%       metric (scalar struct): Reports the metric itself. Has fields:
%           .initial (numeric row vector [1 x nMembers]): The initial metric
%           .updated (numeric vector [N x nMembers]): The updated metric
%               after each iteration of the algorithm.
%
% <a href="matlab:dash.doc('optimalSensor.run')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:run";
dash.assert.scalarObj(obj, header);

% Require essential inputs
obj.assertFinalized;

% Default and error check N
if ~exist('N','var') || isempty(N)
    N = obj.nSite;
else
    dash.assert.scalarType(N, 'numeric', 'N', header);
    dash.assert.indices(N, obj.nSite, 'N', [], 'the number of observation sites', header);
end

% Preallocate and initial output
optimalSites = NaN(N,1);
variance = struct('initial', NaN, 'updated', NaN(N,1));
metric = struct('initial', NaN(1,obj.nMembers), 'updated', NaN(N, obj.nMembers));

% Initialize values
unbias = dash.math.unbias(obj.nMembers);
X = obj.X;

% Get the initial metric, its deviations and its variance
J = obj.computeMetric;
[~, Jdev] = dash.math.decompose(J);
Jvar = dash.math.variance(Jdev, unbias);

metric.initial = J;
variance.initial = Jvar;

% Get R variances and decompose the estimates
R = obj.Rvariances;
[~, Ydev] = dash.math.decompose(obj.Ye);

% Evaluate the relative change in variance for the remaining sites in each
% iteration of the algorithm
for s = 1:N
    deltaVar = obj.varianceReduction(Jdev, Ydev, R, unbias);

    % The optimal site has the greatest reduction of variance
    [~, optimal] = max(deltaVar);
    Ybest = Ydev(optimal, :);
    Rbest = R(optimal);
    optimalSites(s) = optimal;

    % Update ensemble deviations using the optimal site
    [Xmean, Xdev] = dash.math.decompose(X);
    Knum = dash.math.covariance(Xdev, Ybest, unbias);
    Kdenom = dash.kalman.denominator(Ybest, Rbest, unbias);
    K = Knum / Kdenom;
    a = dash.kalman.adjusted(Rbest, Kdenom);
    Xdev = dash.kalman.updateDeviations(Xdev, a, K, Ybest);
    X = Xmean + Xdev;

    % Compute the updated metric
    J = obj.computeMetric(X);
    [~, Jdev] = dash.math.decompose(J);
    Jvar = dash.math.variance(Jdev, unbias);

    variance.updated(s) = Jvar;
    metric.updated(s,:) = J;

    % Remove the optimal site from future consideration
    Ydev(optimal, :) = NaN;

    % Update the estimate deviations
    Knum = dash.math.covariance(Ydev, Ybest, unbias);
    K = Knum / Kdenom;
    Ydev = dash.kalman.updateDeviations(Ydev, a, K, Ybest);
end

end
