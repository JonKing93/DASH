function[obj] = estimates(obj, Ye, whichPrior, header)
%% dash.ensembleFilter.estimates  Provides the estimates to an assimilation filter
% ----------
%   obj = obj.estimates(Ye, whichPrior, header)
%   Sets the observation estimates used by an assimilation filter. The
%   estimates must be a 3D numeric array. NaN, Inf, and complex values are
%   not allowed. Each row is the estimates for a particular observation
%   site, and each column holds the estimates for a particular ensemble
%   member. The third dimension holds the estimates for each ensemble in an
%   evolving set. If the assimilation uses a static prior, this third
%   dimension should be a singleton.
%
%   If the number of evolving ensembles does not match the number of time 
%   steps, then use the whichPrior input to indicate which set of estimates
%   to use in each time step. This input is only necessary if "whichPrior"
%   was not already set by the ensembleFilter.prior method. If the filter
%   uses a static prior, there is exactly one prior per time step, or
%   whichPrior was already set, then whichPrior may be an empty array.
%
%   If Ye is empty, deletes the current estimates from the filter object.
%   If the user previously specified observations or uncertainties, then
%   the number of rows must match the current number of sites. If the user
%   provided a prior, then dimensions 2 and 3 must match the number of
%   ensemble members and evolving priors. If the user provided observations
%   or whichR, then a non-empty whichPrior must match the number of
%   assimilated time steps. If the user already provided whichPrior and a
%   prior, then a non-empty whichPrior must match the previous value.
% ----------
%   Inputs:
%       Ye (numeric 3D array): The observation estimates
%       whichPrior (vector, positive integers [nTime] | []): Indicates
%           which estimates to use in each time step.
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       obj (scalar ensembleFilter object): The filter object with updated
%           estimates.
%
% <a href="matlab:dash.doc('dash.ensembleFilter.estimates')">Documentation Page</a>

% Default
if ~exist('header','var')
    header = "DASH:ensembleFilter:estimates";
end

% If empty, require empty whichPrior
if isempty(Ye)
    if ~isempty(whichPrior)
        id = sprintf('%s:nonemptyWhichPrior', header);
        error(id, 'Since the estimates (Ye) are empty, whichPrior must also be empty.');
    end

    % Delete estimates, optionally reset sizes
    obj = resetEstimates(obj);
    return
end

% Initial error check
name = 'Estimates (Ye)';
dash.assert.blockTypeSize(Ye, 'numeric', [], name, header);
dash.assert.defined(Ye, 1, name, header);

% Get the size of the matrix
[nSite, nMembers, nPrior] = size(Ye);

% Check and set number of sites
if obj.nSite==0
    obj.nSite = nSite;
elseif nSite~=obj.nSite
    mismatchSitesError(obj, nSite, header);
end

% Check and set number of members
if obj.nMembers==0
    obj.nMembers = nMembers;
elseif nMembers ~= obj.nMembers
    mismatchMembersError(obj, nMembers, header);
end

% Check and set number of priors
if obj.nPrior == 0
    obj.nPrior = nPrior;
elseif nPrior ~= obj.nPrior
    mismatchPriorsError(obj, nPriors, header);
end

% Error check and parse whichPrior
obj = obj.parseWhichPrior(obj, whichPrior, header);

end

%% Utilities
function[obj] = resetEstimates(obj)

% Delete estimates
obj.Ye = [];

% Reset sizes
if isempty(obj.R) && isempty(obj.Y)
    obj.nSite = 0;
end
if isempty(obj.X)
    obj.nMembers = 0;
    obj.nPrior = 0;
    obj.whichPrior = 0;
end
if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior)
    obj.nTime = 0;
end

end




