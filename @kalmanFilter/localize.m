function[kf] = localize(kf, wloc, yloc, whichLoc)
%% Specifies localization weights for a Kalman Filter
%
% kf = kf.localize(wloc, yloc)
% Sets the localization weights.
%
% kf = kf.localize(wloc, yloc, whichLoc)
% Use different localization weights in different time steps.
%
% ----- Inputs -----
%
% wloc: State vector localization weights. A numeric matrix with the weights
%    localization weights for the covariance of the state vector with the
%    proxy/observation sites. (nState x nSite).
%
%    If using different localization weights in different time steps, a
%    numeric array with each set of localization weights. (nState x nSite x nLoc)
%
% yloc: A matrix with the localization weights for the covariance of the
%    proxy/observation sites with each other. (nSite x nSite)
%
%    If using multiple sets of localization weights, then a numeric array
%    (nSite x nSite x nLoc).
%
% whichLoc: A vector with one element per time step. Each element is the
%    index of the localization weights to use for that time step. The
%    indices refer to the elements along the third dimension of w.
%
% ----- Outputs -----
%
% kf: The updated Kalman Filter object

% Only allow localization after setting the prior and observations
kf.assertEditableCovariance('covariance localization options');

% Default for whichLoc
if ~exist('whichLoc','var')
    whichLoc = [];
end

% Error check the covariance localization inputs
whichLoc = kf.checkCovariance(wloc, yloc, whichLoc, true);
assert( all(wloc>=0,'all'), 'wloc cannot have negative elements.');
assert( all(yloc>=0,'all'), 'yloc cannot have negative elements.');

% Save the values
kf.wloc = wloc;
kf.yloc = yloc;
kf.whichLoc = whichLoc;
kf.localizeCov = true;

end
