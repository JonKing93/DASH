function[kf] = index(kf, name, weights, rows)

% Require a prior
if isempty(kf.M)
    error('You must specify a prior (using the "prior" command) before creating a posterior index');
end

% Error check the name
name = dash.assertStrFlag(name, "name");
if ~isvarname(strcat('index_', name))
    error('The index name contains values that are not a number, letter, or underscore');
end

% Defaults
if ~exist('weights','var') || isempty(weights)
    weights = ones(kf.nState, 1);
end
if ~exist('rows','var') || isempty(rows)
    rows = 1:kf.nState;
end

% Error check
dash.assertVectorTypeN(rows, 'numeric', [], 'rows');
rows = dash.checkIndices(rows, 'rows', kf.nState, 'number of state vector elements');
dash.assertVectorTypeN(weights, 'numeric', numel(rows), 'weights');

% Add to the calculations array
k = numel(kf.Q)+1;
kf.Q{k,1} = posteriorIndex(name, weights, rows);

end