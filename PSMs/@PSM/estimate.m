function[Ye, R] = estimate(X, F)
%% Estimates proxy values from a state vector ensemble given a set of PSMs
%
% Ye = PSM.computeEstimates(X, F)
% Estimate observations from the ensemble using the PSMs
%
% [Ye, R] = PSM.computeEstimates(X, F)
% Also estimate error-variances from PSMs when possible
%
% ----- Inputs -----
%
% X: A state vector ensemble. A numeric array with up to three dimensions.
%    Size is (nState x nEns x nPrior).
%
% F: A cell vector of PSM objects.
%
% ----- Outputs -----
%
% Ye: Observation estimates for the state vector ensemble and PSMs.
%
% R: Estimate error-variances as estimated by the PSMs.

% Error check
PSM.setupEstimate(X, F);

% Generate the estimates
if nargout==1
    Ye = PSM.computeEstimates(X, F);
else
    [Ye, R] = PSM.computeEstimates(X, F);
end

end