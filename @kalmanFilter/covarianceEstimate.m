function[C, Ycov] = covarianceEstimate(kf, t)
%% Returns the covariance estimate used by a Kalman Filter in a queried time step
%
% [C, Ycov] = kf.covarianceEstimate(t)
%
% ----- Inputs -----
%
% t: The index of an assimilated time step. A scalar positive integer.
%
% ----- Outputs -----
%
% C: The covariance of the state vector elements with the proxy sites
%
% Ycov: The covariance of the proxy sites with one another

% Finalize the filter
kf = kf.finalize;

% Error check t
dash.assertScalarType(t, 't', 'numeric', 'numeric');
t = dash.checkIndices(t, 't', kf.nTime, 'number of time steps');

% If the covariance is set directly, load covariance directly
if kf.setCov
    C = kf.C(:,:, kf.whichCov(t));
    Ycov = kf.Ycov(:,:, kf.whichCov(t));
    
% Otherwise, load and decompose the prior and estimates
else
    X = kf.X(:,:, kf.whichPrior(t));
    Ye = kf.Ye(:,:, kf.whichPrior(t));
    [~, Xdev] = dash.decompose(X, 2);
    [~, Ydev] = dash.decompose(Ye, 2);
    
    % Then estimate the covariance
    [C, Ycov] = kf.estimateCovariance(t, Xdev, Ydev);
end

end