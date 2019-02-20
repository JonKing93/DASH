function[tau] = getTau(X)
%% Calculates the tau quantile value for each element in vector X
%
% tau = getTau(X)
%
% ----- Inputs -----
%
% X: A vector of values
%
% ----- Outputs -----
%
% tau

% Ensure is vector
if ~isvector(X)
    error('X must be a vector');
end

% Get sorting indices for X
[~, sortDex] = sort(X);

% Get the quantile for each value
N = numel(X);
tau(sortDex,1) = 1:N;
tau = (tau - 0.5) ./ N;

% Use the highest quantile for duplicate values
[~, uA, uC] = unique(X, 'last');
tau = tau(uA);
tau = tau(uC);

end