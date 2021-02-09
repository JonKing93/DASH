function[limits] = variableLimits(obj)
%% Returns the row limits of each variable in a state vector.
%
% limits = obj.variableLimits
%
% ----- Outputs -----
%
% limits: A matrix indicating the first and last row of each variable in a
%    state vector. First column is first row, second column is last row.
%    (nVars x 2).

% Get the number of elements per variable
nVars = numel(obj.variables);
nEls = NaN(nVars, 1);
for v = 1:nVars
    nEls(v) = prod(obj.variables(v).stateSize);
end

% Get the limits
limits = dash.buildLimits(nEls);

end
    