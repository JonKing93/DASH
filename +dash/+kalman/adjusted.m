function[Ka] = adjusted(Knum, Kdenom, Rcov)
%% dash.kalman.adjusted  Computes the adjusted Kalman gain for updating ensemble deviations
% ----------
%   Ka = dash.kalman.adjusted(Knum, Kdenom, Rcov)
%   Computes the adjusted Kalman gain for updating ensemble deviations.
% ----------
%   Inputs:
%       Knum (numeric matrix, [nState x nSite]): The numberator of the
%           Kalman gain. This is the covariance of the state vector
%           elements with the observation estimates.
%       Kdenom (symmetric numeric matrix, [nSite x nSite]): The denominator
%           of the Kalman Gain. This is the observation covariances plus
%           the R error covariances.
%       Rcov (symmetric numeric matrix, [nSite x nSite]): The R error covariances
%
%   Outputs:
%       Ka (numeric matrix, [nState x nSite]): The adjusted Kalman gain for
%           updating ensemble deviations.
%
% <a href="matlab:dash.doc('dash.kalman.adjusted')">Documentation Page</a>

Ksqrt = sqrtm(Kdenom);
Ka = Knum * (Ksqrt^-1)' * (Ksqrt + sqrtm(Rcov))^-1;

end