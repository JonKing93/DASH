function[obj] = restoreCovarianceSizes(obj)
%% kalmanFilter.restoreCovarianceSizes  Restore nSite, nState, and nTime set by covariance options
% ----------
%   obj = obj.restoreCovarianceSizes
%   Ensemble filter methods are not aware of covariance options, and may
%   set nTime, nState, and/or nSite to 0 even when these sizes are set by
%   covariance options. This method restores those sizes when they can be
%   set via covariance options.
%
%   Sets nTime according to whichFactor, whichLoc, whichBlend and whichSet.
%   Sets nState and nSite based on the sizes of wloc, Cblend, and Cset.
% ----------
%   Outputs:
%       obj (scalar kalmanFilter object): The Kalman filter object with
%           restored sizes
%
% <a href="matlab:dash.doc('kalmanFilter.restoreCovarianceSizes')">Documentation Page</a>

[nSite, nState, nTime] = obj.covarianceSizes;
if nSite > 0
    obj.nSite = nSite;
end
if nTime > 0
    obj.nTime = nTime;
end
if nState > 0
    obj.nState = nState;
end

end
