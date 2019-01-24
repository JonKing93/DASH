function[varargout] = decomposeEnsemble( X )
%% Break apart an ensemble into mean, deviations, and variance.
%
% [Xmean, Xdev, Xvar] = decomposeEnsemble( X )
% Gets the mean, deviation, and variance of an ensemble.
%
% ----- Inputs -----
%
% X: An ensemble. Each column is one ensemble member. (nState x nEns)
%
% ----- Outputs -----
%
% Xmean: Mean of the ensemble
%
% Xdev: Ensemble deviations
%
% Xvar: Ensemble variance
%

% Mean
Xmean = mean(X,2);
Xdev = X - Xmean;

% If only doing mean and deviation
if nargout<3
    varargout = {Xmean, Xdev};
    
% If also returning variance
elseif nargout==3
    Xvar = var(X, 0, 2);
    varargout = {Xmean, Xdev, Xvar};
end

end