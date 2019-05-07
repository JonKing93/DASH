function[X, tau] = quantMap( Xt, Xs )
%% Quantile mapping
% Maps a value from a source dataset to the value of analogous quantile in 
% a target dataset.
%
% [X, tau] = quantMap( Xt, Xs )
%
% ----- Inputs -----
%
% Xt: A vector containing the target dataset. (nTarget x 1)
%
% Xs: A vector containing the source dataset. (nSource x 1)
%
% ----- Outputs -----
%
% X: The value in Xt in the same quantile as each element in Xs. (nSource x 1)
%
% tau: The quantile of each element in Xs. (nSource x 1)

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