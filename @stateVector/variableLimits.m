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

% Preallocate the limits
nVars = numel(obj.variables);
limits = zeros(nVars+1, 2);

% Get the limit for each variable
for v = 1:nVars
    limits(v+1,1) = limits(v,2)+1;
    limits(v+1,2) = limits(v,2) + prod(obj.variables(v).stateSize);
end
limits(1,:) = [];

end
    