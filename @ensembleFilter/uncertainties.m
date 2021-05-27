function[obj] = uncertainties(obj, R, whichR, isCov)
%% Specify observation uncertainties / error-covariance for a filter
%
% obj.uncertainties(Rvar)
% Specify R uncertainties, the error-variance of observations.
%
% obj.uncertainties(Rvar, whichR)
% Specify which R variance to use in each assimilated time step.
%
% obj.uncertainties(Rcov, whichR, isCov)
% Specify error-covariances for the observations.
%
% ----- Inputs -----
%
% Rvar: Error-variances for the observations. A matrix with one row per
%    observations. If a column vector, uses the same error-variance in each
%    assimilated time step. If the number of columns matches the number of
%    time steps, uses the relevant variances for each time step. For any
%    other number of columns, you must specify which R variance to use in
%    each time step using the second input. All R variances must be
%    positive.
%
% Rcov: Error-covariances for the observations. An array with dimensions
%   (nSite x nSite x nR). If you do not specify the second input, must
%   either have one element along the third dimension, or one element per
%   time step. Each error-covariance matrix must be symmetric with positive
%   diagonal elements.
%
% whichR: A vector with one element per time step. Each element is the
%    index of the set of R variances/covariances to use for that time step.
%    The indices refer to the column of Rvar, or the index along the third
%    dimension of Rcov, as appropriate.
%
% isCov: A scalar logical that indicates whether the uncertainties are R
%    error-variances (false -- Default) or error-covariances (true)
%
% ----- Outputs -----
%
% obj: The updated filter object

% Default and error check covariance toggle
if ~exist('isCov','var') || isempty(isCov)
    isCov = false;
end
dash.assertScalarType(isCov, 'isCov', 'logical', 'logical');

% Get sizes
if ~isCov
    [nSite, nR] = obj.checkInput(R, 'Rvar', true, true);
else
    [nSite, nSite2, nR] = obj.checkInput(R, 'Rcov', true, false);
    assert(nSite==nSite2, sprintf('The number of rows in Rcov (%.f) does not match the number of columns (%.f)', nSite, nSite2));
end

% Default and parse whichR
if ~exist('whichR','var') || isempty(whichR)
    whichR = [];
end
resetTime = isempty(obj.Y) && isempty(obj.whichPrior);
whichR = obj.parseWhich(whichR, 'whichR', nR, 'R uncertainties', resetTime);
nTime = numel(whichR);

% Size checks
if nSite~=obj.nSite
    assert(isempty(obj.Y), sprintf('You previously specified observations for %.f sites, but R has %.f sites (rows)', obj.nSite, nSite));
    assert(isempty(obj.Ye), sprintf('You previously specified estimates for %.f sites, but R has %.f sites (rows)', obj.nSite, nSite));
end
if nTime~=obj.nTime && ~isempty(whichR)
    assert(isempty(obj.Y), sprintf('You previously specified observations for %.f time steps, but these R values are for %.f time steps', obj.nTime, nTime));
    assert(isempty(obj.whichPrior), sprintf('You previously specified a transient prior for %.f time steps, but these R values are for %.f time steps', obj.nTime, nTime));
end

% Check values are variances or covariances
if ~isCov
    assert(~any(R(:)<=0), 'R variances must be greater than 0.');

else
    for c = 1:nR
        Rc = R(:,:,c);
        Rnan = isnan(Rc);
        Rc(Rnan) = 1;
        assert( issymmetric(Rnan) && issymmetric(Rc), sprintf('R covariance %.f is not a symmetric matrix', c));                
        assert( ~any(diag(Rc)<=0), sprintf('The diagonal elements of R covariance %.f must be greater than 0', c));
    end
end

% Save values
obj.R = R;
obj.Rcov = isCov;
obj.nSite = nSite;
obj.nR = nR;

if ~isempty(whichR)
    obj.whichR = whichR;
    obj.nTime = nTime;
end

% Check for missing R values
obj.checkMissingR;

end