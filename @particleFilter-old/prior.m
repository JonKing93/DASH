function[pf] = prior(pf, X, whichPrior)
%% Specify the prior(s) for a particle filter
%
% pf = pf.prior(X)
% Specify a static or evolving offline prior to use in each time step.
%
% pf = pf.prior(X, whichPrior)
% Specifies evolving offline priors and indicates which prior to use in
% each time step.
%
% ----- Inputs -----
%
% M: A static offline or evolving offline prior. A numeric array that
%    cannot contain Inf or complex values.
%
%    Static: M is a matrix (nState x nEns) and will be used as the
%       prior in each time step.
%
%    Evolving: M is an array (nState x nEns x nPrior). If you do
%    not provide a second input, must have one prior per time step.
%
% whichPrior: A vector with one element per time step. Each element
%    is the index of the prior to use for that time step. The indices refer
%    to the index along the third dimension of M. (nTime x 1)
%
% ----- Outputs -----
%
% pf: The updated particleFilter object

% Default whichPrior
if ~exist('whichPrior','var') || isempty(whichPrior)
    whichPrior = [];
end

% Record current nEns and apply standard error checking
nEns = pf.nEns;
pf = prior@ensembleFilter(pf, X, whichPrior);

% Check for size conflicts with the weighting scheme
assert(nEns==pf.nEns || pf.weightType~=1 || pf.weightArgs>pf.nEns, sprintf(...
    ['You previously specified a weighting scheme for the best %.f particles, ',...
    'but the new prior only has %.f particles (ensemble members, columns)'], ...
    pf.weightArgs, pf.nEns));

end