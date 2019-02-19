function[tau] = getTau(X)

% Ensure is vector
if ~isvector(X)
    error('X must be a vector');
end

% Get sorting indices for Xs
[~, sortDex] = sort(Xs);

% Get the quantile for each value
N = numel(X);
tau(sortDex,1) = 1:N;
tau = (tau - 0.5) ./ N;

% Use the highest quantile for duplicate values
[~, uA, uC] = unique(X, 'last');
tau = tau(uA);
tau = tau(uC);

end