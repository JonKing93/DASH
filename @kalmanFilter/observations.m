function[varargout] = observations(obj, Y)
%% kalmanFilter.observations  Set or return the observations for a Kalman filter
% ----------
%   obj = obj.observations(Y)
%   Provides the observation matrix (Y) to the Kalman filter object.
%   Overwrites any previously existing observation matrix. Each row holds
%   the observations for a particular site, and each column holds
%   observations for an assimilation time step. Use a NaN value when a site
%   does not have an observations in a particular time step. Inf and
%   complex values are not allowed.
%
%   Y = obj.observations
%   Returns the current observation matrix for the Kalman filter object.
%
%   obj = obj.observations('delete')
%   Deletes any current observation matrix from the Kalman filter object.
% ----------
%   Inputs:
%       Y (numeric matrix [nSite x nTime]): The proxy observations to use
%           in a Kalman filter. A numeric matrix with one row per
%           proxy site, and one column per assimilated time steps. Use NaN
%           for records that lack an observation in a particular time step.
%           Inf and complex values are not allowed.
%
%   Outputs:
%       obj (scalar kalmanFilter object): The kalmanFilter object with
%           updated proxy observations
%
% <a href="matlab:dash.doc('kalmanFilter.observations')">Documentation Page</a>

% Header
header = "DASH:kalmanFilter:observations";

% Use cell wrapper for inputs
if ~exist('Y','var')
    Y = {};
else
    Y = {Y};
end

% Parse the observations
[varargout, type] = observations@dash.ensembleFilter(obj, header, Y{:});
varargout = obj.validateSizes(varargout, type, 'observations', header);

end