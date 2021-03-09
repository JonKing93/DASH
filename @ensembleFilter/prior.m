function[obj] = prior(obj, X, whichPrior)
%% Specify the prior(s) for a filter
%
% obj = obj.prior(X)
% Specify a static or evolving offline prior to use in each time step.
%
% obj = obj.prior(X, whichPrior)
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
% obj: The updated ensembleFilter object

% Default whichPrior
if ~exist('whichPrior','var') || isempty(whichPrior)
    whichPrior = [];
end

% Error check M and get the size
[nState, nEns, nPrior] = obj.checkInput(X, 'X', true);

% Check for size conflicts
assert(isempty(obj.Ye) || nEns==obj.nEns, sprintf('You previously specified observation estimates for %.f ensemble members, but X has %.f ensemble members (columns)', obj.nEns, nEns);
assert(isempty(obj.Ye) || nPrior==obj.nPrior, sprintf('You previously specified observation estimates for %.f priors, but X has %.f priors (elements along dimension 3)', obj.nPrior, nPrior);

% Parse and error check whichPrior
whichPrior = obj.parseWhich(whichPrior, 'whichPrior', nPrior, 'prior');

% Set values
obj.nState = nState;
obj.nEns = nEns;
obj.nPrior = nPrior;
if ~isempty(whichPrior)
    obj.nTime = numel(whichPrior);
end
obj.X = X;
obj.whichPrior = whichPrior;

end