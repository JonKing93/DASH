function[deltaVar] = varianceReduction(Jdev, Ydev, Rvar, unbias)
%% optimalSensor.varianceReduction  Evaluates the reduction of variance for sites in an optimal sensor
% ----------
%   deltaVar = optimalSensor.varianceReduction(Jdev, Ydev, Rvar, unbias)
%   Computes the reduction in variance of a sensor metric for each site in
%   an optimal sensor. The returned reductions in variance indicate the
%   variance reduction that occurs when assimilating each site
%   individually, without any of the other sites.
% ----------
%   Inputs:
%       Jdev (numeric row vector [1 x nMembers]): The ensemble deviations 
%           of the sensor metric
%       Ydev (numeric matrix [nSite x nMembers]): The ensemble deviations
%           of the observation estimates.
%       R (numeric column vector [nSite x 1]): The R uncertainty variances
%           for each optimal sensor site.
%       unbias (scalar positive integer): The coefficient of unbiased estimation
%
%   Outputs:
%       deltaVar (numeric column vector [nSite]): The reduction in metric
%           variance that occurs when assimilating each site.
%
% <a href="matlab:dash.doc('optimalSensor.varianceReduction')">Documentation Page</a>

Yvar = dash.math.variance(Ydev, unbias);
deltaVar = (unbias * (Ydev * Jdev')).^2 ./ (Yvar + Rvar);

end