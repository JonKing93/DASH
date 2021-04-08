function[Ye, R] = estimate(X, F, throwError)
%% Estimates proxy values from a state vector ensemble given a set of PSMs
%
% Ye = PSM.estimate(X, F)
% Estimate observations from the ensemble using the PSMs
%
% [Ye, R] = PSM.estimate(X, F)
% Also estimate error-variances from PSMs when possible
%
% [...] = PSM.estimate(X, F, throwError)
% Throws an error when a PSM fails, rather than issuing a warning. Useful
% when trying to debug new PSMs.
%
% ----- Inputs -----
%
% X: A state vector ensemble. A numeric array with up to three dimensions.
%    Size is (nState x nEns x nPrior).
%
% F: A cell vector of PSM objects.
%
% throwError: A scalar logical indicating whether to throw an error when a
%    PSM fails (true), or instead issue a warning (false -- Default)
%
% ----- Outputs -----
%
% Ye: Observation estimates for the state vector ensemble and PSMs.
%
% R: Estimate error-variances as estimated by the PSMs.

% Defaults
if ~exist('throwErrors','var') || isempty(throwError)
    throwError = [];
end

% Error check
F = PSM.setupEstimate(X, F);

% Generate the estimates
if nargout==1
    Ye = PSM.computeEstimates(X, F);
else
    [Ye, R] = PSM.computeEstimates(X, F, throwError);
end

end