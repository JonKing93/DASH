function[varargout] = uncertainties(obj, R, whichR, type)
%% particleFilter.uncertainties  Set or return the proxy uncertainties for a particle filter
% ----------
%   obj = <strong>obj.uncertainties</strong>(Rvar)
%   Provides error variances to the particle filter object. Overwrites any
%   previous set of uncertainties. Each row holds the uncertainties for a
%   particular site. Each column holds a unique set of error variances. If
%   Rvar has a single column, uses the same set of error variances in all
%   assimilation time steps. If the number of sets of variances matches the
%   number of time steps, uses the indicated set of variances in each time
%   step. For a given set of variances, a NaN value is permitted for a site
%   if the site has no observations in that time step.
%
%   obj = <strong>obj.uncertainties</strong>(Rcov)
%   Provides error covariances to the particle filter object. Overwrites
%   any previous set of uncertainties. Rcov should have one row and one
%   column for each observation site. Each element along the third
%   dimension holds a unique set of covariances. Each set of covariances
%   must be a symmetric matrix. If there is a single set of covariances,
%   uses the same covariances in all assimilation time steps. If the number
%   of sets of covariances matches the number of time steps, uses the
%   indicated set of covariances in each time step. For a given set of
%   covariances, NaN values are permitted between two sites if at least one
%   of the two sites is missing an observation in that time step.
%
%   obj = <strong>obj.uncertainties</strong>(R, whichR)
%   Specify which set of R variances or covariances to use in each
%   assimilation time steps. This syntax allows the number of sets of R
%   values to differ from the number of time steps.
%
%   obj = <strong>obj.uncertainties</strong>(R, whichR, type)
%   obj = <strong>obj.uncertainties</strong>(R, whichR, "c"|"cov"|"covariance"|true)
%   obj = <strong>obj.uncertainties</strong>(R, whichR, "v"|"var"|"variance"|false)
%   Indicate the type of uncertainties being provided to the particle
%   filter. If "c"|"cov"|"covariance"|true, treats the input uncertainties
%   as covariances. If "v"|"var"|"variance"|false, treats the uncertainties
%   as variances.
%
%   [R, whichR] = <strong>obj.uncertainties</strong>
%   Returns the R uncertainties for the particle filter object, and
%   indicates which set of R variances or covariances is used in each
%   assimilation time step.
%
%   obj = <strong>obj.uncertainties</strong>('delete')
%   Deletes any current uncertainties from the particle filter object.
% ----------
%   Inputs:
%       Rvar (numeric matrix [nSite x 1|nTime|nR]): Error variances for the
%           proxies. A numeric matrix with one row per site. Each column is
%           a unique set of variances. If there is a single column, uses
%           the same set of error variances in all assimilation time steps.
%           If the number of sets of variances matches the number of time
%           steps, uses the indicated set of variances in each time step.
%           If the number of sets of variances is neither 1 nor the number
%           of time steps, use the whichR input to indicate which set of
%           variances to use in each assimilation time step. For a given
%           set of variances, a NaN value is permitted for a site if the
%           site has no observations in all time steps associated with that
%           set of error variances.
%       Rcov (numeric array [nSite x nSite x 1|nTime|nR]): Error
%           covariances for the proxies. A numeric array with one row and
%           one column per site. Each element along the third dimension is
%           a unique set of covariances. Each set of covariances must be a
%           symmetric matrix. If there is a single set of covariances
%           (i.e. Rcov is a matrix), uses the same set of covariances for 
%           all assimilation time step. If the number of sets of covariances
%           matches the number of time steps, uses the indicated set of
%           covariances in each time step. If the number of sets of 
%           covariances is neither 1 nor the number of time steps, use the
%           whichR input to indicate which set of covariances to use in each
%           assimilated time step. For a given set of covariances, NaN
%           values are permitted between two sites if at least one of the
%           sites is missing an observation in all time steps associated
%           with the that set of covariances.
%       whichR (vector, positive integers [nTime]): Indicates which set of
%           R variances or covariances to use in each time step. Must have
%           one element per assimilation time step. Each element of whichR
%           is the index of a set of R variances or covariances. If using R
%           variances, these indices are for the columns of Rvar. If using
%           R covariances, these indices are for the thrid dimension of Rcov.
%       type (string scalar | scalar logical): Indicates whether the
%           uncertainties are variances or covariances
%           ["v"|"var"|"variance"|false]: Error variances
%           ["c"|"cov"|"covariance"|true]: Error covariances
%   
%   Outputs:
%       obj (scalar particleFilter object): The particleFilter object with
%           updated R uncertainties
%       Rvar (numeric matrix [nSite x 1|nTime|nR]): The current error
%           variances for a particleFilter object. If you have not
%           provided R uncertainties, an empty array.
%       Rcov (numeric array [nSite x nSite x 1|nTime|nR]): The current
%           error covariances for the particleFilter object. If you have not
%           provided R uncertainties, an empty array.
%       whichR (vector, positive integers [nTime] | []): Indicates which
%           set of R variances or covariances is used in each assimilation
%           time step. If there is a single set of R variances or
%           covariances, returns an empty array.
%
% <a href="matlab:dash.doc('particleFilter.uncertainties')">Documentation Page</a>

% Header
header = "DASH:particleFilter:uncertainties";

% Use a cell wrapper for inputs
if ~exist('R','var')
    inputs = {};
elseif ~exist('whichR','var')
    inputs = {R};
elseif ~exist('type','var')
    inputs = {R, whichR};
else
    inputs = {R, whichR, type};
end

% Parse the uncertainties
varargout = uncertainties@dash.ensembleFilter(obj, header, inputs{:});

end