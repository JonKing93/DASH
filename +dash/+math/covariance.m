function[XYcov] = covariance(Xdev, Ydev, unbias)
%% dash.math.covariance  Compute the cross covariance between two sets of ensemble deviations
% ----------
%   XYcov = dash.math.covariance(Xdev, Ydev, unbias)
%   Computes the cross covariance between two sets of ensemble deviations.
%   Each ensemble may contain a different number of elements (rows), but the
%   total number of ensemble members (columns) should be the same for the
%   two ensembles.
% ----------
%   Inputs:
%       Xdev (numeric matrix [N x nMembers]): A set of ensemble deviations
%       Ydev (numeric matrix [M x nMembers]): A second set of ensemble deviations
%       unbias (numeric scalar): The coefficient for unbiased estimation
%
%   Outputs:
%       XYcov (numeric matrix [N x M]): The cross covariance between the
%           two sets of ensemble deviations
%
% <a href="matlab:dash.doc('dash.math.covariance')">Documentation Page</a>

XYcov = unbias .* (Xdev * Ydev');

end