function[Rvar] = Rvariances(obj)
%% optimalSensor.Rvariances  Returns the R uncertainty variances for the optimal sensor sites
% ----------
%   Rvar = obj.Rvariances
%   Returns the R uncertainty variance for each site in an optimal sensor.
%   If the sensor uses R covariances, extracts variances from the diagonal
%   of the covariance matrix and neglects all inter-site covariances.
% ----------
%   Outputs:
%       Rvar (numeric column vector [nSite]): The R uncertainty variance
%           for each optimal sensor site
%
% <a href="matlab:dash.doc('optimalSensor.Rvariances')">Documentation Page</a>

if obj.Rtype==0
    Rvar = obj.R;
else
    Rvar = diag(obj.R);
end

end