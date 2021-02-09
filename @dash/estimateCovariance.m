function[C, Ycov] = estimateCovariance(X, Y)
%% Estimates covariance for a state vector ensemble and proxy estimates
%
% [C, Ycov] = dash.estimateCovariance(X, Y)
%
% ----- Inputs -----
%
% X: A state vector ensemble. A numeric matrix with dimensions
%    (State vector x Ensemble members). May not contain NaN or Inf.
%
% Y: Model estimates of proxies/observations. A numeric matrix of size 
%    (Proxy sites x Ensemble members). Must have the same number of columns
%     as X. May not contain NaN or Inf.
%
% ----- Outputs -----
%
% C: The covariance of the state vector elements with the proxy sites. A
%    numeric matrix of size (State vector x Proxy sites)
%
% Ycov: The covariance of the proxy sites with one another. A symmetric
%    matrix of size (Proxy sites x Proxy sites)

% Error check the inputs
[~, nEns] = kalmanFilter.checkInput(X, 'X', false, true);
[~, nEns2] = kalmanFilter.checkInput(Y, 'Y', false, true);
assert(nEns==nEns2, 'Y and X must have the same number of columns');

% Decompose
[~, Xdev] = dash.decompose(X, 2);
[~, Ydev] = dash.decompose(Y, 2);

% Estimate covariances
unbias = 1/(nEns-1);
C = unbias .* (Xdev * Ydev');
Ycov = unbias .* (Ydev * Ydev');

end