function[kf] = prior(kf, M, whichPrior)
%% Specify the prior(s) for a Kalman Filter
%
% kf = kf.prior(M)
% Specify a static or evolving offline prior to use in each time step.
%
% kf = kf.prior(M, whichPrior)
% Specifies evolving offline priors and indicates which prior to use in
% each time step.
%
% ----- Inputs -----
%
% M: A static offline or evolving offline prior. A numeric array that
%    cannot contain NaN or Inf.
%
%    Static offline: M is a matrix (nState x nEns) and will be used as the
%       prior in each time step.
%
%    Evolving offline: M is an array (nState x nEns x nPrior). If you do
%    not provide a second input, must have one prior per time step.
%
% whichPrior: A vector with one element per time step. Each element
%    is the index of the prior to use for that time step. The indices refer
%    to the index along the third dimension of M. (nTime x 1)
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Error check M and get the size
[nState, nEns, nPrior] = kf.checkInput(M, 'M');

% Check there are no size conflicts
if ~isempty(kf.Y) && nEns~=kf.nEns
    error(['You previously specified observation estimates for a %.f member ensemble, ',...
        'but M has %.f ensemble members (columns).'], kf.nEns, nEns);
elseif ~isempty(kf.Y) && nPrior~=kf.nPrior
    error(['You previously specified observation estimates for %.f priors, ',...
        'but M includes %.f priors (the length of dimension 3).'], kf.nPrior, nPrior);
end

% Note if this is an evolving prior
isevolving = false;
if nPrior > 1
    isevolving = true;
end

% If evolving, get the prior to use in each time step
notvar = ~exist('whichPrior','var') || isempty(whichPrior);
if isevolving
    if notvar && (nPrior==kf.nTime || kf.nTime==0)
        whichPrior = 1:kf.nTime;
        kf.nTime = nPrior;
    elseif notvar
        error(['The number of priors (%.f) does not match the number of time ',...
            'steps, so you must use the second input (whichPrior) to specify ',...
            'which prior to use in each time step.'], nPrior, kf.nTime);
    end
    
    % Error check whichPrior
    assert(isnumeric(whichPrior) && isvector(whichPrior), 'whichPrior must be a numeric vector');
    assert(numel(whichPrior)==kf.nTime, sprintf('You previously specified observations for %.f time steps, so whichPrior must have %.f elements', kf.nTime, kf.nTime));    
    dash.checkIndices(whichPrior, 'whichPrior', nPrior, 'the number of priors');

% If a static prior, cannot select time steps
else
    if ~notvar
        error(['You have specified a static prior, so you cannot use the second ',...
            'input (whichPrior) to specify time steps.']);
    end
    whichPrior = [];
end

% Set values
kf.M = M;
kf.whichPrior = whichPrior(:);
kf.nState = nState;
kf.nEns = nEns;
kf.nPrior = nPrior;

end