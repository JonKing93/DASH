function[kf] = index(kf, name, weights, rows)
%% Returns the posterior for an index calculated over the updated ensemble
%
% kf = kf.index(name)
% Returns the posterior for a mean calculated over the entire state vector.
%
% kf = kf.index(name, weights)
% Calculates a weighted mean over the entire state vector.
%
% kf = kf.index(name, weights, rows)
% Calculates a weighted mean over specific state vector rows.
%
% ----- Inputs -----
%
% name: The name of the index. A string. May only contain numbers, letters,
%    and underscores.
%
% weights: A numeric vector containing weights for a weighted mean. Must
%    either have one element per state vector element, or one element per
%    specified row.
%
% rows: A vector indicating the rows to use when calculating the index.
%    Either a logical vector the length of the state vector, or a set of
%    linear indices.
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Require a prior
if isempty(kf.M)
    error('You must specify a prior (using the "prior" command) before creating a posterior index');
end

% Error check the name
name = dash.assertStrFlag(name, "name");
outputName = strcat('index_', name);
assert(isvarname(outputName), 'name can only contain numbers, letters, and underscores');
assert(~ismember(outputName, kf.Qname), sprintf('You already specified an index named %s', name));

% Defaults
if ~exist('weights','var') || isempty(weights)
    weights = ones(kf.nState, 1);
end
if ~exist('rows','var') || isempty(rows)
    rows = 1:kf.nState;
end

% Error check
rows = dash.checkIndices(rows, 'rows', kf.nState, 'number of state vector elements');
dash.assertVectorTypeN(weights, 'numeric', numel(rows), 'weights');

% Add to the calculations array
k = numel(kf.Q)+1;
kf.Q{k,1} = posteriorIndex(outputName, weights, rows);

end