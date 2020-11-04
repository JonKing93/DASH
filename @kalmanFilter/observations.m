function[kf] = observations(kf, D, R)
%% Specify the observations and observation uncertainty for a Kalman Filter
%
% kf = kf.observations(D, R)
%
% ----- Inputs -----
%
% D: The observations/proxy values. A numeric matrix. Each row has the
%    observations for one site over all time steps. Use NaN in time steps
%    with no observations. (nSite x nTime)
%
% R: The observation uncertainty. Use a numeric matrix the size of D 
%    (nSite x nTime) to specify the uncertainty for each observation. Use a
%    scalar (1 x 1) to use the same uncertainty for all observations. If a
%    column vector (nSite x 1), uses a fixed value for each proxy site in
%    all time steps. If a row vector (1 x nTime), uses a fixed value for
%    all proxy sites in each time step.
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Error check D and get size
assert(isnumeric(D) & ismatrix(D), 'D must be a numeric matrix.');
dash.assertRealDefined(D, 'D', true);
assert(~isempty(D), 'D cannot be empty.');
[nSite, nTime] = size(D);

% Check that the number of sites doesn't conflict with the estimates. Also
% check the number of time steps doesn't conflict with an evolving prior.
if ~isempty(kf.Y) && nSite~=kf.nSite
    error(['You previously specified observation estimates for %.f sites, ',...
        'but D only has %.f sites (rows).'], kf.nSite, nSite);
elseif ~isempty(kf.whichPrior) && nTime~=kf.nTime
    error(['You previously specified an evolving prior for %.f time steps, ',...
        'but D only has %.f time steps (columns).'], kf.nTime, nTime);
end

% Error check R.
assert(isnumeric(R) & ismatrix(R), 'R must be a numeric matrix.');
dash.assertRealDefined(R, 'R', true);
assert(~isempty(R), 'R cannot be empty');
assert( ~any(R(:)<=0), 'R can only include positive values.')

% Propagate R over D
[nSite, nTime] = size(D);
if isscalar(R)
    R = repmat(R, [nSite, nTime]);
elseif isrow(R)
    R = repmat(R, [nSite, 1]);
elseif iscolumn(R)
    R = repmat(R, [1 nTime]);
end

% Check sizes match
if size(R,1)~=nSite
    error('The number of rows in R (%.f) does not match the number of rows of D (%.f).', size(R,1), nSite);
elseif size(R,2)~=nTime
    error('The number of columns in R (%.f) does not match the number of columns of D (%.f)', size(R,2), nTime);
end

% Require every observation to have an uncertainty.
missing = ~isnan(D) & isnan(R);
if any(missing, 'all')
    nMissing = sum(missing, 'all');
    [row, col] = find(missing, 1);
    error(['There are %.f observations missing an associated uncertainty. ',...
        'The first missing uncertainty is for site (row) %.f in time step (column) %.f.'],...
        nMissing, row, col);
end

% Set values
kf.D = D;
kf.R = R;
kf.nSite = nSite;
kf.nTime = nTime;

end
