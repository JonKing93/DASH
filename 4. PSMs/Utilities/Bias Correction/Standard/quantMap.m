function[X, tau] = quantMap( Xt, Xs )
%% Quantile mapping
% Maps a value from a dataset to the value of analogous quantile in a 
% second dataset.
%
% [X, tau] = quantMap( Xt, Xs )
%
% ----- Inputs -----
%
% Xs: A vector containing the source dataset.
%
% Xt: A vector containing the target dataset.
%
% ----- Outputs -----
%
% X: The value in Xt in the same quantile as each element in Xs.
%
% tau: The quantile of each element in Xs.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check that Xs and Xt are vectors
if ~isvector(Xs) || ~isvector(Xt)
    error('Xs and Xt must be vectors.')
end

% Get the tau values
[~,sortDex] = sort(Xs);

% Get the quantile for each value
N = numel(Xs);
tau(sortDex,1) = 1:N;
tau = (tau-0.5) ./ N;
    
% Use the highest tau value for duplicate quantiles
[~, uA, uC] = unique(Xs, 'last');
tau = tau(uA);
tau = tau(uC);

% Lookup the tau values against the target distribution
X = quantile( Xt, tau );

end