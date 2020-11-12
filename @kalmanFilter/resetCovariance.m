function[kf] = resetCovariance(kf)
%% Resets the covariance options for a Kalman Filter. Removes any inflation
% factor, localization, blending options, or user-specified covariance.
%
% kf = kf.resetCovariance;
%
% ----- Output -----
%
% kf: The udpated kalmanFilter object

kf.inflateCov = false;
kf.inflateFactor = [];
kf.localizeCov = false;
kf.wloc = [];
kf.yloc = [];
kf.whichLoc = [];
kf.setCov = false;
kf.blendCov = false;
kf.C = [];
kf.Ycov = [];
kf.whichCov = [];
kf.blendWeights = [];

end