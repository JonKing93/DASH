function[optimalSites, variance, metric] = run(obj, N)
%% optimalSensor.run  Runs the optimal sensor algorithm
% ----------
%   [optimalSites, variance, metric] = obj.run
%   Runs the optimal sensor algorithm. Runs the algorithm until every
%   observation site has been ranked and used to update the metric.
%
%   [optimalSites, variance, metric] = obj.run(N)
%   Runs the optimal sensor algorithm for the N best sensors. The number of
%   sensors cannot exceed the number of sites for the object.
%
%   The following is an outline of the optimal sensor algorithm:
%     The method begins by evaluating each observation site in the network.
%     The sites are ranked by their ability to reduce the variance of the
%     sensor metric across the ensemble. This evaluation only considers the
%     variance reduction that occurs when the site is assimilated alone.
%     The site that is most strongly reduces metric variance is deemed the
%     "optimal sensor", and that single site is then used to update the
%     metric's ensemble deviations. The optimal site is also used to update
%     the observations estimates. The optimal sensor site is then removed
%     from the network, and the algorithm is repeated using the
%     remaining/updated estimates and the updated metric. This process
%     iterates until the requested number of sensors have been selected and
%     used to update the metric.
%
%   **Important**
%   Because this method only assimilates a single site at a time, it only
%   considers R uncertainty variances. If observation errors are strongly
%   correlated (such that R uncertainty covariances are required), then
%   this may not be the most suitable method. You can use the
%   "optimalSensor.update" method to evaluate the change in variance that
%   occurs when assimilating observation sites with correlated errors.
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
%           equal to the number of observation sites.
%
%   Outputs:
%       optimalSites (vector, linear indices [N]): Indicates the optimal
%           observation site for each iteration of the optimal sensor
%           algorithm. Has one element per selected optimal sensor. Each
%           element is the index of the observation site selected as
%           optimal for that iteration. The first element is the first
%           optimal site, the second element is the next optimal site after the
%           first site has been used to update the prior and removed from
%           the network, etc.
%       variance (numeric vector [N]): The variance of the metric after
%           each optimal site has been used to update the metric's ensemble
%           deviations. Essentially, the remaining metric variance after
%           assimilating each optimal site. Has one element per iteration
%           of the algorithm.
%       metric (numeric matrix [N x nMembers]): The updated metric after
%           each iteration of the algorithm. Each row is the metric after
%           an additional optimal site has been used to update the metric's
%           ensemble deviation. Each column is an ensemble member.
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

% Preallocate
optimalSites = NaN(N, 1);
variance = NaN(N, 1);
metric = NaN(N, obj.nMembers);

% Decompose the metric and estimates
[Jmean, Jdev] = dash.math.decompose(obj.J);
[~, Ydev] = dash.math.decompose(obj.Ye);

% Get the R variances and coefficient for an unbiased estimator
Rvar = obj.Rvariances;
unbias = dash.math.unbias(obj.nMembers);

% For each iteration of the algorith, evaluate the variance reduced by the
% remaining sites in the network
for s = 1:N
    deltaVar = obj.varianceReduction(Jdev, Ydev, Rvar, unbias);

    % The optimal site causes the greatest reduction of variance. Get the
    % estimates and R variance associated with this site.
    [~, optimal] = max(deltaVar);
    Rbest = Rvar(optimal);
    Ybest = Ydev(optimal, :);
    Yvar = dash.math.variance(Ybest, unbias);

    % Use the optimal site to update the metric's deviations
    Knum = dash.math.covariance(Jdev, Ybest, unbias);
    Kdenom = dash.kalman.denominator(Yvar, Rbest);
    Ka = dash.kalman.adjusted(Knum, Kdenom, Rbest);
    Jdev = dash.kalman.updateDeviations(Jdev, Ka, Ybest);

    % Also update the estimates and remove the optimal site from
    % consideration in future iterations of the algorithm
    Ydev = dash.kalman.updateDeviations(Ydev, Ka, Ybest);
    Ydev(optimal, :) = NaN;

    % Update the outputs
    optimalSites(s) = optimal;
    variance(s) = dash.math.variance(Jdev, unbias);
    metric(s,:) = Jmean + Jdev;
end

end
