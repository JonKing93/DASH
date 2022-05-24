function[varargout] = estimates(obj, Ye, whichPrior)
%% kalmanFilter.estimates  Set or return the estimates for a Kalman filter
% ----------
%   obj = obj.estimates(Ye)
%   Provides a set of observation estimates (Ye) for a kalman filter.
%   Overwrites any previously input estimates. Each row hold the estimates
%   for a particular site, and each column holds the estimates for an
%   ensemble member. Each element along the third dimension holds the
%   estimates for a particular prior in an evolving set. If using a static prior, Ye should
%   have a single element along the third dimension. Otherwise, Ye must
%   have one element along the third dimension per assimilation time step -
%   in this case, the Kalman filter will use the indicated set of
%   estimates for each assimilated time step.
%
%   obj = obj.estimates(Ye, whichPrior)
%   Indicate which set of estimates to use in each assimilation time step.
%   This syntax allows the number of sets of estimates (i.e. the number of
%   priors) to differ from the number of time steps.
%
%   [Ye, whichPrior] = obj.estimates
%   Returns the current estimates for the Kalman filter object, and
%   indicates which set of estimates (i.e. which prior) is used in each
%   assimilation time step.
%
%   obj = obj.estimates('delete')
%   Deletes any current estimates from the Kalman filter object.
% ----------
%   Inputs:
%       Ye (numeric matrix [nSite x nMembers x 1|nTime|nPrior]): Proxy
%           estimates for the Kalman filter. A numeric array with one row
%           per site, and one column per ensemble member. Each element
%           along the third dimension holds the estimates for a unique
%           prior. If using a static prior, Ye should have one element
%           along the third dimension. If the number of elements along the
%           third dimension matches the number of time steps, uses the
%           appropriate set of estimates for each time step. If the number
%           of priors is neither 1 nor the number of time steps, use the
%           whichPrior input to indicate which set of estimates to use in
%           each assimilation time step. NaN values are not permitted.
%       whichPrior (vector, positive integers [nTime]): Indicates which set
%           of estimates to use in each assimilation time step. 
%           Must have one element per assimilation time step. Each
%           element of whichPrior is the index of a particular prior -
%           essentially, the index of an element along the third dimension
%           of Ye.
%
%   Outputs:
%       obj (scalar kalmanFilter object): The kalmanFilter object with
%           updated estimates
%       Ye (numeric matrix [nSite x nMembers x 1|nTime|nPrior]): The
%           current estimates forthe kalmanFilter object. If you have not
%           provided estimates, an empty array.
%       whichPrior (vector, positive integers [nTime] | []): Indicates
%           which set of estimates (i.e. which prior) is used in each
%           assimilation time step. If there is a static prior, returns an
%           empty array.
%
% <a href="matlab:dash.doc('kalmanFilter.estimates')">Documentation Page</a>

% Header
header = "DASH:kalmanFilter:estimates";

% Use a cell wrapper for inputs
if ~exist('Ye', 'var')
    inputs = {};
elseif ~exist('whichPrior','var')
    inputs = {Ye};
else
    inputs = {Ye, whichPrior};
end

% Parse the estimates
varargout = estimates@dash.ensembleFilter(obj, header, inputs{:});

end