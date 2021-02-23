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

% Parse the ensemble and get sizes
assert(isnumeric(X), 'X must be numeric');
dash.assertRealDefined(X, 'X');
assert(ndims(X)<=3, 'X cannot have more than 3 dimensions');
nState = size(X, 1);

% Parse the PSM vector
nSite = numel(F);
[F, wasCell] = dash.parseInputCell(F, nSite, 'F');
name = "F";

% Error check the individual PSMs
for s = 1:nSite
    if wasCell
        name = sprintf('Element %.f of F', s);
    end
    dash.assertScalarType(F{s}, name, 'PSM', 'PSM');

    % Check the rows of the PSM do not exceed the number of rows
    if max(F{s}.rows) > nState
        error('The ensemble has %.f rows, but %s uses rows that are larger (%.f)', ...
            nState, F{s}.messageName(s), max(F{s}.rows));
    end
end   

end