function[pf] = estimates(pf, Y, whichPrior)
%% Specify the model estimates of the observations/proxies for a filter
%
% pf = pf.estimates(Y)
%
% ----- Inputs -----
%
% Y: The model estimates of observations/proxies. A numeric array that
%    cannot contain NaN or Inf. (nSite x nEns x nPrior)
%
% ----- Outputs -----
%
% pf: The updated particleFilter object

% Record current nEns and apply standard error checking
nEns = pf.nEns;
pf = estimates@ensembleFilter(pf, Y, whichPrior);

% Check for size conflicts with the weighting scheme
if nEns~=pf.nEns && pf.weightType==1 && pf.weightArgs>pf.nEns
    error(['You previously specified a weighting scheme for the best %.f particles, ',...
        'but the new prior only has %.f particles (ensemble members, columns)'], pf.weightArgs, pf.nEns);
end

end