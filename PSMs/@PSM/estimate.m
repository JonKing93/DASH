function[Ye, R] = estimate(X, F)

% Error check
PSM.setupEstimate(X, F);

% Generate the estimates
if nargout==1
    Ye = PSM.computeEstimates(X, F);
else
    [Ye, R] = PSM.computeEstimates(X, F);
end

end