function[varargout] = prior(obj, X, whichPrior)
%% particleFilter.prior  Set or return the prior for a particle filter
% ----------
%   obj = obj.prior(X)
%   Provide the prior for a particle filter direclty as a numeric array. 
%   Overwrites any previously specified prior. Each row is a state vector
%   element, and each column is an ensemble member. Each element along the
%   third dimension holds a particular prior in an evolving set. If using a
%   static prior, X should have a single element along the third dimension. 
%   Otherwise, X should have one element along the third dimension per 
%   assimilation time step. In this case, the particle filter will use the
%   indicated prior for each assimilated time step.
%
%   obj = obj.prior(ens)
%   Provide the prior using ensemble objects. To implement a static prior,
%   the input should be a scalar ensemble object that implements a static
%   prior. 
% 
%   For evolving priors, the input may either be:
%   1. A scalar ensemble object that implements an evolving ensemble, or
%   2. A vector of ensemble objects that all implement static ensembles.
%   In the first case, the number of priors for the assimilation will match
%   the number of ensembles in the evolving set. In the second case, the
%   number of priors for the assimilation will match the number of elements
%   in the vector of ensemble objects. The number of evolving priors must
%   match the number of assimilation time steps (although see the syntax
%   below for relaxing that requirement). If using a vector of ensemble
%   objects, all the objects must implement ensembles with the same number
%   of state vector elements (nRows) and ensemble members (nMembers).
%
%   obj = obj.prior(  X, whichPrior)
%   obj = obj.prior(ens, whichPrior)
%   Indicate which prior to use in each assimilation time step. This syntax
%   allows the number of priors to differ from the number of time steps.
%
%   [  X, whichPrior] = obj.prior
%   [ens, whichPrior] = obj.prior
%   Returns the current prior for the particle filter object, and indicates
%   which prior is used in each assimilation time step.
%
%   obj = obj.prior('delete')
%   Deletes the current prior(s) from the particle filter object.
% ----------
%   Inputs:
%       X (numeric matrix [nState x nMembers x 1|nTime|nPrior]): The
%           prior(s) for the particle filter. A numeric array with one row
%           per state vector element, and one column per ensemble member.
%           Each element along the third dimension holds a unique prior. If
%           using a static prior, X should have one element along the third
%           dimension. If the number of priors matches the number of time
%           steps, uses the appropriate prior for each time step. If the
%           number of priors is neither 1 nor the number of time steps, use
%           the whichPrior input to indicate which prior to use in each
%           assimilation time step. If the prior for a state vector element
%           includes NaN values in a particular time step, then the updated
%           state vector element will be NaN in that time step.
%       ens (scalar ensemble object <static | evolving [nPrior]> | 
%            vector, <static> ensemble objects [nPrior]):
%           The prior for the particle filter, provided via ensemble
%           objects. For a static prior, a scalar ensemble object that
%           implements a static ensemble. For an evolving ensemble, either
%           a scalar ensemble object that implements an evolving ensemble,
%           OR a vector of ensemble objects that implement static
%           ensembles. If providing a vector of ensemble objects, each
%           object must implement an ensemble with the same number of state
%           vector elements (rows) and ensemble members (columns). If the
%           number of priors matches the number of time steps, uses the
%           appropriate prior for each time step. If the number of priors
%           is neither 1 nor the number of time steps, use the whichPrior
%           input to indicate which prior to use in each assimilation time
%           step. If the prior for a state vector element includes NaN
%           values in a particular time step, then the updated state vector
%           element will be NaN in that time step.
%       whichPrior (vector, positive integers [nTime]): Indicates which
%           prior to use in each assimilation time step. Must have one element
%           per assimilation time step.
%
%   Outputs:
%       obj (scalar particleFilter object): The particleFilter object with the
%           udpated prior.
%       X (numeric matrix [nState x nMembers x 1|nTime|nPrior]): The current
%           prior for the particleFilter object. If you have not provided a
%           prior, returns an empty array.
%       ens (scalar ensemble object <static | evolving [nPrior]> | 
%            vector, <static> ensemble objects [nPrior]):
%           The current prior for the particleFilter object. If you have not
%           provided a prior, returns an empty array.
%       whichPrior (vector, positive integers [nTime] | []): Indicates which
%           prior is used in each assimilation time step. If there is a static
%           prior, returns an empty array.
%
% <a href="matlab:dash.doc('particleFilter.prior')">Documentation Page</a>

% Header
header = "DASH:particleFilter:prior";

% Use a cell wrapper for inputs
if ~exist('X', 'var')
    inputs = {};
elseif ~exist('whichPrior','var')
    inputs = {X};
else
    inputs = {X, whichPrior};
end

% Parse the estimates
[varargout, type] = prior@dash.ensembleFilter(obj, header, inputs{:});

% Check for conflicts with best N weights when altering members
if obj.weightType==1 && (strcmpi(type,'set') || strcmpi(type,'delete'))
    obj = varargout{1};
    obj = obj.validateBestN(type, 'prior', header);
    varargout = {obj};
end

end