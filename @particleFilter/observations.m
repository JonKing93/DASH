function[varargout] = observations(obj, Y)
%% particleFilter.observations  Set or return the observations for a particle filter
% ---------
%   obj = obj.observations(Y)
%   Provides the observation matrix (Y) to the particle filter object.
%   Overwrites any previously existing observation matrix. Each row holds
%   the observations for a particular site, and each column holds
%   observations for an assimilation time step. Use a NaN value when a site
%   does not have an observations in a particular time step. Inf and
%   complex values are not allowed.
%
%   If you already provided observation uncertainties or estimates, then 
%   then number of rows must match the current number of sites for the
%   particle filter object. If you previously provided evolving priors or
%   evolving uncertainties, then the number of columns must match the
%   current number of assimilation time steps for the object.
%
%   Y = obj.observations
%   Returns the current observation matrix for the particle filter object.
%
%   obj = obj.observations('delete')
%   Deletes any current observation matrix from the particle filter object.
% ----------
%   Inputs:
%       Y (numeric matrix [nSite x nTime]): The proxy observations to use
%           in a particle filter. A numeric matrix with one row per
%           proxy site, and one column per assimilated time steps. Use NaN
%           for records that lack an observation in a particular time step.
%           Inf and complex values are not allowed.
%
%   Outputs:
%       obj (scalar particleFilter object): The particleFilter object with
%           updated proxy observations
%
% <a href="matlab:dash.doc('particleFilter.observations')">Documentation Page</a>

% Note: This method is mostly just a wrapper to the superclass method. It should
% remain a distinct method so that the particleFilter documentation
% (intended for users), remains separate from ensembleFilter documnetation
% (intended for developers).

% Header
header = "DASH:particleFilter:observations";

% Use cell wrapper for inputs
if ~exist('Y','var')
    Y = {};
else
    Y = {Y};
end

% Parse the observations
varargout = observations@dash.ensembleFilter(obj, header, Y{:});

end