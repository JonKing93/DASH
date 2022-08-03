function[Knum, Ycov] = estimateCovariance(obj, t, s, Xdev, Ydev)
%% kalmanFilter.estimateCovariance  Estimates Kalman filter covariance for a queried time step
% ----------
%   [Knum, Ycov] = obj.estimateCovariance(t, s)
%   Returns the user-specified covariance estimate for a queried time step
%   a requested observation sites.
%
%   [Knum, Ycov] = obj.estimateCovariance(t, s, Xdev, Ydev)
%   Estimates covariance from ensemble deviations and applies inflation,
%   localization, and blending (in that order) as appropriate.
% ----------
%   Inputs:
%       t (scalar linear index): The index of an assimilation time step for
%           which to estimate and return covariance
%       s (vector, linear indices [nQuery]): The indices of observation sites for
%           which to estimate and return covariance.
%       Xdev (numeric matrix [nState x nMembers]): The ensemble deviations 
%           for the prior for the time step. 
%       Ydev (numeric matrix [nSite x nMembers]): The ensemble deviations
%           of the estimates for the time step. Must have one row per
%           observation site in the filter, regardless of the number of
%           queried sites.
%
%   Outputs:
%       Knum (numeric matrix [nState x nQuery]): The covariance of the state
%           vector elements with the queried observation sites. This
%           covariance is the numerator of the Kalman Gain.
%       Ycov (numeric matrix [nQuery x nQuery]): The covariance between the
%           queried observation sites and each other. This covariance is
%           the Y covariance term that appears in the denominator of the
%           Kalman gain.
%
% <a href="matlab:dash.doc('kalmanFilter.estimateCovariance')">Documentation Page</a>

% Load covariance directly if set by user
if ~isempty(obj.Cset)
    c = obj.whichSet(t);
    Knum = obj.Cset(:,s,c);
    Ycov = obj.Yset(s,s,c);

% Otherwise, estimate covariance from ensemble deviations
else
    Ydev = Ydev(s,:);
    unbias = dash.math.unbias(obj.nMembers);
    Knum = dash.math.covariance(Xdev, Ydev, unbias);
    Ycov = dash.math.covariance(Ydev, Ydev, unbias);

    % Inflate
    if ~isempty(obj.inflationFactor)
        c = obj.whichFactor(t);
        factor = obj.inflationFactor(c);
        Knum = factor .* Knum;
        Ycov = factor .* Ycov;
    end

    % Localize
    if ~isempty(obj.wloc)
        c = obj.whichLoc(t);
        Knum = obj.wloc(:,s,c) .* Knum;
        Ycov = obj.yloc(s,s,c) .* Ycov;
    end

    % Blend
    if ~isempty(obj.Cblend)
        c = obj.whichBlend(t);
        w = obj.blendingWeights(c,:);
        
        Knum = (w(1) .* obj.Cblend(:,s,c))  +  (w(2) .* Knum);
        Ycov = (w(1) .* obj.Yblend(s,s,c))  +  (w(2) .* Ycov);
    end
end

end
