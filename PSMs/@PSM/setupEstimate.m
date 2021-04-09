function[F] = setupEstimate(X, F)
%% Error checks an ensemble and PSMs before estimating proxies.
%
% PSM.checkEstimate(X, F)
%
% ----- Inputs -----
%
% X: A model ensemble
%
% F: Either a scalar PSM object or a cell vector of PSM objects
%
% ----- Outputs -----
%
% F: PSM inputs as a cell vector.

% Error check the ensemble and get sizes
assert(isnumeric(X), 'X must be numeric');
dash.assertRealDefined(X, 'X');
assert(ndims(X)<=3, 'X cannot have more than 3 dimensions');
[nState, nEns, nPrior] = size(X);

% Parse the PSM vector
nSite = numel(F);
[F, wasCell] = dash.parseInputCell(F, nSite, 'F');
name = "F";

% Error check the individual PSMs
for s = 1:nSite
    psm = F{s};
    if wasCell
        name = sprintf('Element %.f of F', s);
    end
    dash.assertScalarType(psm, name, 'PSM', 'PSM');

    % Check the PSM rows match ensemble sizes
    name = psm.messageName(s);
    maxrow = max(psm.rows, [], 'all');
    [~, nEns2, nPrior2] = size(psm.rows);
    
    if maxrow > nState
        error('The ensemble has %.f rows, but %s uses rows that are larger (%.f)', ...
            nState, psm.messageName(s), maxrow);
    elseif nEns2~=1 && nEns2~=nEns
        error('The ensemble has %.f members (columns), but %s specifies rows for %.f ensemble members', ...
            nEns, psm.messageName(s), nEns2);
    elseif nPrior2~=1 && nPrior2~=nPrior
        error('The ensemble has %.f priors (elements along dimension 3), but %s specifies rows for %.f priors', ...
            nPrior, psm.messageName(s), nPrior2);
    end
end   

end