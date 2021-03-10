function[kf] = index(kf, name, weights, rows, nanflag)
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
% kf = kf.index(name, weights, rows, nanflag)
% Specify how to treat NaN values in the weighted mean for the index. By
% default, NaN values are included in means.
%
% kf = kf.index(name, 'delete')
% Removes an index from the output.
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
% nanflag: Options are "includenan" to use NaN values (default) and
%    "omitnan" to remove NaN values.
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Require a prior
if isempty(kf.X)
    error('You must specify a prior (using the "prior" command) before creating a posterior index');
end

% Error check the name
name = dash.assertStrFlag(name, "name");
outputName = strcat('index_', name);
assert(isvarname(outputName), 'name can only contain numbers, letters, and underscores');

% Defaults
if ~exist('weights','var') || isempty(weights)
    weights = ones(kf.nState, 1);
end
if ~exist('rows','var') || isempty(rows)
    rows = 1:kf.nState;
end
if ~exist('nanflag','var')
    nanflag = "includenan";
end

% Parse 

% Delete the index if requested
if dash.isstrflag(weights) && strcmpi(weights, 'delete')
    delete = strcmp(outputName, kf.Qname);
    assert(any(delete), sprintf('There is no index named %s', name));
    kf.Q(delete,:) = [];
    kf.Qname(delete,:) = [];
    
% Otherwise, error check the inputs
else
    dash.assertVectorTypeN(weights, 'numeric', numel(rows), 'weights');
    assert(~ismember(outputName, kf.Qname), sprintf('You already specified an index named %s', name));
    rows = dash.checkIndices(rows, 'rows', kf.nState, 'number of state vector elements');
    dash.assertStrFlag(nanflag, 'nanflag');
    assert(any(strcmpi(nanflag, ["omitnan","includenan"])), 'nanflag must either be "omitnan" or "includenan"');

    % Add to the calculations array
    k = numel(kf.Q)+1;
    kf.Q{k,1} = posteriorIndex(outputName, weights, rows, nanflag);
    kf.Qname(k,1) = outputName;
end

end