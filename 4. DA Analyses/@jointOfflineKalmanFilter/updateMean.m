function[Amean] = updateMean( Mmean, K, D, Ymean )
% Updates the ensemble mean
%
% Mmean: nState x nTime
%
% K: nState x nSite
%
% innov: nSite x nTime
%
% Amean: nState x nTime

Amean = Mmean + K * (D - Ymean);

end