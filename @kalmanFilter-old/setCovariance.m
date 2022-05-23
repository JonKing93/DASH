function[kf] = setCovariance(kf, C, Ycov, whichCov)
%% Sets the covariance directly for a Kalman Filter
%
% kf = kf.setCovariance(C, Ycov)
% Specify a covariance estimate to use in each time step.
%
% k = kf.setCovariance(C, Ycov, whichCov)
% Specify different covariance estimates to use in different time steps.
%
% ----- Inputs -----
%
% C: The covariance of each observation/proxy site with the state vector. 
%    A numeric matrix (nState x nSite)
%
%    If using different covariances in different time steps, then an
%    array (nState x nSite x nCov)
%
% Ycov: The covariance of each observation/proxy site with the other 
%    observation/proxy sites. (nSite x nSite)
%
%    If using different covariances in different time steps, then an
%    array (nSite x nSite x nCov)
%
% whichCov: A vector with one element per time step. Each element is the
%    index of the covariance to blend for that time step. The indices refer
%    to the elements along the third dimension of C.
%     
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Cannot set covariance if blending or if prior/observations are unset
if kf.blendCov
    error('Cannot set the covariance directly after specifying blending options. If needed, you can reset the covariance options using the "resetCovariance" command.');
end
kf.assertEditableCovariance('the covariance');

% Error check the covariance inputs
if ~exist('whichCov','var') || isempty(whichCov)
    whichCov = [];
end
whichCov = kf.checkCovariance(C, Ycov, whichCov);

% Save the values
kf.C = C;
kf.setCov = true;
kf.Ycov = Ycov;
kf.whichCov = whichCov;

end