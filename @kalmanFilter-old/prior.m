function[kf] = prior(kf, X, whichPrior)
%% Specify the prior(s) for a Kalman Filter
%
% kf = kf.prior(X)
% Specify a static or evolving offline prior to use in each time step.
%
% kf = kf.prior(X, whichPrior)
% Specifies evolving offline priors and indicates which prior to use in
% each time step.
%
% ----- Inputs -----
%
% X: A static offline or evolving offline prior. A numeric array that
%    cannot contain Inf or complex values.
%
%    Static: X is a matrix (nState x nEns) and will be used as the
%       prior in each time step.
%
%    Evolving: X is an array (nState x nEns x nPrior). If you do
%    not provide a second input, must have one prior per time step.
%
% whichPrior: A vector with one element per time step. Each element
%    is the index of the prior to use for that time step. The indices refer
%    to the index along the third dimension of M. (nTime x 1)
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Default whichPrior
if ~exist('whichPrior','var') || isempty(whichPrior)
    whichPrior = [];
end

% Record current nState and apply standard error checking
nState = kf.nState;
kf = prior@ensembleFilter(kf, X, whichPrior);

% Check for size conflicts with Kalman filter settings
assert(nState==kf.nState || isempty(kf.wloc), sprintf(['You previously ',...
    'specified localization weights for %.f state vector elements, but X has %.f ', ...
    'state vector elements (rows).'], nState, kf.nState));
assert(nState==kf.nState || isempty(kf.C), sprintf(['You previously specified a ',...
    'covariance estimate for %.f state vector elements, but X has %.f state ',...
    'vector elements (rows).'], nState, kf.nState));
assert(nState==kf.nState || isempty(kf.Qname) || ~any(contains(kf.Qname,"index")), ...
    sprintf(['You previously specified a posterior index, so you cannot change ',...
    'the number of state vector elements. X must have %.f state vector ',...
    'elements (rows), but instead has %.f.'], nState, kf.nState));

end