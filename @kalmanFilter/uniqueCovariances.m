function[whichCov, nCov] = uniqueCovariances(obj, t)
%% kalmanFilter.uniqueCovariances  Locates unique covariances in a set of queried time steps
% ----------
%   [whichCov, nCov] = obj.uniqueCovariances(t)
%   Given a set of queried assimilation time steps, determines which of the
%   queried time steps share a unique covariance estimate. Also returns the
%   total number of unique covariance estimates across the time steps.
% ----------
%   Inputs:
%       t (vector, linear indices [nTime]): The indices of queried
%           assimilation time steps.
%   
%   Outputs:
%       whichCov (vector, linear indices [nTime]): Indicates which queried
%           time steps share the same covariance estimate. Has one element
%           per queried time step. Each element holds the index of one of
%           the unique covariance estimates for the queried time steps.
%           Time steps that use the same covariance will have the same
%           value in whichCov.
%       nCov (scalar positive integer): The total number of unique
%           covariance estimates for the queried time steps.
%
% <a href="matlab:dash.doc('kalmanFilter.uniqueCovariances')">Documentation Page</a>

% Get the covariance settings in the queried time steps
if ~isempty(obj.Cset)
    covSettings = obj.whichSet(t);
else
    covSettings = [obj.whichPrior(t), obj.whichFactor(t), obj.whichLoc(t), obj.whichBlend(t)];
end

% Get the unique sets of covariances and associated time steps
[covSettings, ~, whichCov] = unique(covSettings, 'rows');
nCov = size(covSettings, 1);

end