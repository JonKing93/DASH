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
% obj: The updated ensembleFilter object

% Error check M and get the size
[nState, nEns, nPrior] = obj.checkInput(X, 'X', true);

% Check there are no size conflicts
if ~isempty(obj.Y) && nEns~=obj.nEns
    error(['You previously specified Y estimates with %.f ensemble members, ',...
        'but X has %.f ensemble members (columns).'], obj.nEns, nEns);
elseif ~isempty(obj.Y) && nPrior~=obj.nPrior
    error(['You previously specified Y estimates for %.f priors, but X has ',...
        '%.f priors (elements along dimension 3).'], obj.nPrior, nPrior);
end

% Default and error check whichPrior
whichPrior = obj.parseWhich(whichPrior, 'whichPrior', nPrior, 'prior');

% Set values
obj.M = X;
obj.whichPrior = whichPrior;
obj.nState = nState;
obj.nEns = nEns;
obj.nPrior = nPrior;
if ~isempty(whichPrior)
    obj.nTime = numel(whichPrior);
end

end