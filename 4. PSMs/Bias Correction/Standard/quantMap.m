function[X, tau] = quantMap( Xt, Xs, Xd )
%% Quantile mapping
% Maps a value from a dataset to the value of analogous quantile in a 
% second dataset.
%
% [X, tau] = quantMap( Xt, Xs )
%
% [X, tau] = quantMap( Xt, Xs, Xd )
% Does a static quantile mapping for the values in Xd
%
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
if exist('Xd','var') && ~isvector(Xd)
    error('Xd must be a vector.');
end

% Get the tau values from the source data
tau = getTau(Xs);

% If a static lookup, interpolate to the tau values for Xd
if exist('Xd','var')
    tau = interp1( Xs, tau, Xd );
end

% Lookup the tau values against the target distribution
X = quantile( Xt, tau );

end