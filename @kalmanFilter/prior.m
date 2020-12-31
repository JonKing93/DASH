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
% kf: The updated kalmanFilter object

% Error check M and get the size
[nState, nEns, nPrior] = kf.checkInput(M, 'M');

% Check there are no size conflicts
if ~isempty(kf.wloc) && nState~=kf.nState
    error(['You previously specified localization weights for %.f state vector ',...
        'elements, but M only has %.f state vector elements (rows).'], kf.nState, nState);
elseif ~isempty(kf.C) && nState~=kf.nState
    error(['You previously specified a covariance estimate for %.f state vector ',...
        'elements, but M only has %.f state vector elements (rows).'], kf.nState, nState);
elseif ~isempty(kf.Qname) && any(contains(kf.Qname, "index")) && nState~=kf.nState
    error(['You previously specified a posterior index, so you cannot change ',...
        'the number of state vector elements. M must have %.f state vector ',...
        'elements (rows), but instead has %.f.'], kf.nState, nState);
elseif ~isempty(kf.Y) && nEns~=kf.nEns
    error(['You previously specified Y estimates with %.f ensemble members, ',...
        'but M has %.f ensemble members (columns).'], kf.nEns, nEns);
elseif ~isempty(kf.Y) && nPrior~=kf.nPrior
    error(['You previously specified Y estimates for %.f priors, but M has ',...
        '%.f priors (elements along dimension 3).'], kf.nPrior, nPrior);
end

% Check if whichPrior exists
isvar = exist('whichPrior','var') && ~isempty(whichPrior);

% If there is a single prior, whichPrior is not allowed
if nPrior==1
    if isvar
        error(['You have provided a static prior, so you cannot use the second ',...
            'input (whichPrior) to specify time steps.']);
    end
    whichPrior = [];
    
% Otherwise, there is an evolving prior. Require whichPrior unless the
% number of priors exactly matches time steps (or time is undefined)
else
    if ~isvar && (nPrior==kf.nTime || kf.nTime=0)
        kf.nTime = nPrior;
        whichPrior = 1:kf.nTime;    
    elseif ~isvar
        error(['The number of priors (%.f) does not match the number of time ',...
            'steps (%.f), so you must use the second input (whichPrior) to ',...
            'specify which prior to use in each time step.'], nPrior, kf.nTime);
    end

    % Error check whichPrior
    dash.assertVectorTypeN(whichPrior, 'numeric', kf.nTime, 'whichPrior');
    dash.checkIndices(whichPrior, 'whichPrior', nPrior, 'the number of priors');
end

% Set values
kf.M = M;
kf.whichPrior = whichPrior(:);
kf.nState = nState;
kf.nEns = nEns;
kf.nPrior = nPrior;

end