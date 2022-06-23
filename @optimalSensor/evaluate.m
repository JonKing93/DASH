function[deltaVariance] = evaluate(obj)
%% optimalSensor.evaluate  Evaluates the variance reduced by individual proxies in a network
% ----------
%   deltaVariance = obj.evaluate
%   For each observation site, evaluates the amount of the metric's
%   variance that is reduced when the site is assimilated alone. Evaluates
%   the *individual* influence of each proxy observation on an assmilation.
%   
%   **Important**
%   This method neglects the covariance between observation sites, and only
%   considers the effects of assimilating each site individually. In general,
%   when observation estimates covary, their total effect on the metric's
%   variance will be smaller than the sum of their individual effects. Use
%   the "optimalSensor.update" method to assess the total effect on metric
%   variance when multiple estimates covary. Also note that we are *not*
%   referring to R uncertainty covariances here. This effect still occurs
%   when using R uncertainty variances.
% ----------
%   Outputs:
%       deltaVariance (numeric vector [nSites]): The reduction of variance
%           that occurs when assimilating each site individually.
%   
% <a href="matlab:dash.doc('optimalSensor.evalute')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:evaluate";
dash.assert.scalarObj(obj, header);

% Require essential data inputs
obj.assertFinalized;

% Decompose the metric and the estimates
[~, Jdev] = dash.math.decompose(obj.J);
[~, Ydev] = dash.math.decompose(obj.Ye);

% Assess the effect of each site on metric variance
unbias = dash.math.unbias(obj.nMembers);
Rvar = obj.Rvariances;
deltaVariance = obj.varianceReduction(Jdev, Ydev, Rvar, unbias);

end