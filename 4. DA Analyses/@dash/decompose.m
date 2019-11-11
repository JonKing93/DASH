function[varargout] = decompose( X )
%% Break apart an ensemble into mean, deviations, and variance.
%
% [Xmean, Xdev, Xvar] = dash.decompose( X )
% Gets the mean, deviation, and variance of an ensemble.
%
% ----- Inputs -----
%
% X: An ensemble. (nState x nEns)
%
% ----- Outputs -----
%
% Xmean: Mean of the ensemble (nState x 1)
%
% Xdev: Ensemble deviations (nState x nEns)
%
% Xvar: Ensemble variance (nState x 1)

% Mean
Xmean = mean(X,2);
Xdev = X - Xmean;

% If only doing mean and deviation
if nargout<3
    varargout = {Xmean, Xdev};
    
% If also returning variance
elseif nargout==3
    Xvar = sum( Xdev.^2, 2 ) ./ (size(X,2)-1);
    varargout = {Xmean, Xdev, Xvar};
end

end