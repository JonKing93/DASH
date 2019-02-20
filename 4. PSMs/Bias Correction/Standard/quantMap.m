function[X, tau] = quantMap( Xs, Xt )
%% Quantile mapping
% Maps a value from a dataset to the value of analogous quantile in a 
% second dataset.
%
% [X, tau] = quantMap( Xs, Xt )
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
tau = getTau(Xs);

% Lookup the tau values against the target distribution
X = quantile( Xt, tau );

end