function[obj] = saveMeanArgs(obj, weights, rows)
%% Error check and save input arguments for 

% Default inputs
if ~exist('weights','var') || isempty(weights)
    weights = (1/obj.nState) * ones(obj.nState, 1);
end
if ~exist('rows','var') || isempty(rows)
    rows = 1:obj.nState;
end

% Error check the inputs
dash.assertVectorTypeN(weights, 'numeric', numel(rows), 'weights');
rows = dash.checkIndices(rows, 'rows', obj.nState, 'number of state vector elements');

% Save the arg structure
denom = sum(weights);
obj.metricArgs = struct('weights',weights,'rows',rows,'denom',denom);

end