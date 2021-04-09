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
% X: An offline prior. A numeric array that cannot contain Inf or complex values.
%
%    Static: X is a matrix (nState x nEns) and will be used as the
%       prior in each time step.
%
%    Transient: X is an array (nState x nEns x nPrior). If you do
%       not provide a second input, must have one prior per time step.
%
% whichPrior: A vector with one element per time step. Each element
%    is the index of the prior to use for that time step. The indices refer
%    to the index along the third dimension of M. (nTime x 1)
%
% ----- Outputs -----
%
% obj: The updated ensembleFilter object

% Error check data type and get sizes
[nState, nEns, nPrior] = obj.checkInput(X, 'X', true);

% Default and parse whichPrior
if ~exist('whichPrior','var') || isempty(whichPrior)
    whichPrior = [];
end
resetTime = isempty(obj.Y) && isempty(obj.whichR);
whichPrior = obj.parseWhich(whichPrior, 'whichPrior', nPrior, 'prior', resetTime);
nTime = numel(whichPrior);

% Size checks
if ~isempty(obj.Ye)
    assert( nEns==obj.nEns, sprintf('You previously specified estimates for %.f ensemble members, but X has %.f ensemble members (columns)', obj.nEns, nEns));
    assert( nPrior==obj.nPrior, sprintf('You previously specified estimates for %.f priors, but X has %.f priors (elements along dimension 3)', obj.nPrior, nPrior));
end
if nTime~=obj.nTime && ~isempty(whichPrior)
    assert(isempty(obj.Y), sprintf('You previously specified observations for %.f time steps, but here you specify transient priors for %.f time steps', obj.nTime, nTime));
    assert(isempty(obj.whichR), sprintf('You previously specified R uncertainties for %.f time steps, but here you specify transient priors for %.f time steps', obj.nTime, nTime));
end

% If there is a whichPrior for estimates, require the same time steps
if ~isempty(whichPrior) && ~isempty(obj.whichPrior) && ~isempty(obj.Ye)
    assert(isequal(whichPrior, obj.whichPrior), 'The time steps for the transient priors do not match the time steps specified for the associated estimates. (check the whichPrior input)');
end

% Save
obj.X = X;
obj.nState = nState;
obj.nEns = nEns;
obj.nPrior = nPrior;

if ~isempty(whichPrior)
    obj.whichPrior = whichPrior;
    obj.nTime = nTime;
end

end