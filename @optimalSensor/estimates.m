function[obj] = estimates(obj, Ye, R)
%% Specify estimates directly for an optimal sensor test. Estimates will be
% updated directly via the Kalman Gain.
%
% obj = obj.estimates(Ye, R)
%
% ----- Inputs -----
%
% Ye: Proxy estimates for the sensor sites. A numeric matrix that cannot
%    contain NaN or Inf. Each row is a site. Columns correspond to the
%    ensemble members (columns) of the prior.
%
% R: Uncertainty estimates for the proxy estimates. A numeric vector with
%    one element per proxy site. Cannot contain NaN.
%
% ----- Outputs -----
%
% obj: The updated optimalSensor object

% Check the function can be called
assert(~isempty(obj.X), 'You must specify a prior before you can provide estimates');
assert(~obj.hasPSMs, 'You cannot provide estimates for this optimal sensor test because you already specified a set of PSMs.');

% Error check
assert(isnumeric(Ye), 'Ye must be numeric');
assert(ismatrix(Ye), 'Ye must be a matrix');
dash.assertRealDefined(Ye, 'Ye');
[nSite, nEns] = size(Ye);
assert(nEns==obj.nEns, sprintf(['You previously specified a prior with %.f ',...
    'ensemble members (columns), but Ye has %.f columns'], obj.nEns, nEns));

dash.assertVectorTypeN(R, 'numeric', nSite, 'R');
dash.assertRealDefined(R, 'R');
assert(~any(R<=0), 'R can only include positive values');

% Save
obj.Ye = Ye;
obj.R = R;
obj.nSite = nSite;
obj.hasEstimates = true;

end