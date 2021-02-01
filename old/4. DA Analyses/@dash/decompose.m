function[Xmean, Xdev] = decompose( X )
%% Break apart an ensemble into mean, deviations, and variance.
%
% [Xmean, Xdev] = dash.decompose( X )
% Gets the mean and deviations from the mean for an ensemble.
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

Xmean = mean(X,2);
Xdev = X - Xmean;

end