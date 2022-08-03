function[Kdenom] = denominator(Ycov, Rcov)
%% dash.kalman.denominator  Computes the denominator of the Kalman Gain
% ----------
%   Kdenom = dash.kalman.denominator(Ycov, Rcov)
%   Computes the denominator of the Kalman Gain. This is the sum of the R
%   uncertainty error-covariances and the covariances between the
%   observation estimates.
% ----------
%   Inputs:
%       Ycov (symmetric numeric matrix [nSite x nSite]): The covariances of
%           the observation estimates with one another.
%       Rcov (symmetric numeric matrix [nSite x nSite]): The R uncertainty
%           error covariances
%
%   Outputs:
%       Kdenom (symmetric numeric matrix [nSite x nSite]): The denominator
%           of the Kalman gain.
%
% <a href="matlab:dash.doc('dash.kalman.denominator')">Documentation Page</a>

Kdenom = Ycov + Rcov;

end