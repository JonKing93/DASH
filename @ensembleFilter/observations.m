function[obj] = observations(obj, D, R, isCovariance)
%% Specify the observations and observation uncertainty for a filter
%
% obj = obj.observations(D, Rvar)
% Specify observations and error-variances.
%
% obj = obj.observations(D, Rcov, true)
% Specify observations and error-covariances. Necessary when observation
% sites have correlated errors.
%
% obj = obj.observations(D, R, isCovariance)
% Specify whether error-variances or error-covariances are provided.
%
% ----- Inputs -----
%
% D: The observations/proxy values. A numeric matrix. Each row has the
%    observations for one site over all time steps. Use NaN in time steps
%    with no observations. (nSite x nTime)
%
% Rvar: Observation uncertainty/error-variances. Use a numeric matrix the size of D 
%    (nSite x nTime) to specify the uncertainty for each observation. Use a
%    scalar (1 x 1) to use the same uncertainty for all observations. If a
%    column vector (nSite x 1), uses a fixed value for each proxy site in
%    all time steps. If a row vector (1 x nTime), uses a fixed value for
%    all proxy sites in each time step.
%
% Rcov: Observations error-covariances. Use a matrix (nSite x nSite) to use
%    the same error covariance in each time step. Use an array 
%    (nSite x nSite x nTime) to specify the error covariance for each time
%    step.
%
% type: A scalar logical indicating whether the R values are error
%    covariances (true) or error variances (false). By default, assumes
%    that R values are error variances.
%
% ----- Outputs -----
%
% obj: The updated ensembleFilter object

% Default for covariance vs variance
if ~exist('isCovariance','var') || isempty(isCovariance)
    isCovariance = false;
end
dash.assertScalarType(isCovariance, 'isCovariance', 'logical', 'logical');

% Error check D and R. Get sizes from D
[nSite, nTime] = obj.checkInput(D, 'D', true, true);
requireMatrix = true;
if isCovariance
    obj.checkInput(R, 'Rcov', true, false);
    assert(ndims(R)<=3, 'Rcov cannot have more than 3 dimensions');
else
    obj.checkInput(R, 'Rvar', true, requireMatrix);
end

% Check that the number of sites doesn't conflict with the estimates. Also
% check the number of time steps doesn't conflict with an evolving prior.
if ~isempty(obj.Y) && nSite~=obj.nSite
    error(['You previously specified observation estimates for %.f sites, ',...
        'but D has %.f sites (rows).'], obj.nSite, nSite);
elseif ~isempty(obj.whichPrior) && nTime~=obj.nTime
    error(['You previously specified an evolving prior for %.f time steps, ',...
        'but D has %.f time steps (columns).'], obj.nTime, nTime);
end

% Error check R variance
if ~isCovariance
    [rows, cols] = size(R);
    assert(rows==1 || rows==nSite, sprintf('The number of rows in Rvar (%.f) does not match the number of rows in D (%.f)', rows, nSite));
    assert(cols==1 || cols==nTime, sprintf('The number of columns in Rvar (%.f) does not match the number of columns in D (%.f)', cols, nTime));
    assert( ~any(R(:)<=0), 'R can only include positive values.');
    
    % Propagate R over time steps
    if rows==1
        R = repmat(R, [nSite, 1]);
    end
    if cols==1
        R = repmat(R, [1, nTime]);
    end
    
    % Check for missing variances
    [row, col] = find(isnan(D) & isnan(R), 1);
    assert(isempty(row), sprintf('You must provide an R variance for proxy %.f in time step %.f', row, col));
    
% Error check R covariance
else
    [rows, cols, siz3] = size(R);
    assert(rows==nSite, sprintf('The number of rows in Rcov (%.f) does not match the number of rows in D (%.f)', rows, nSite));
    assert(rows==cols, sprintf('The number of columns in Rcov (%.f) must match the number of rows (%.f)', cols, rows));
    assert(siz3==1 || siz3==nTime, sprintf('The number of elements along the third dimension of Rcov (%.f) does not match the number of time steps (columns) in D (%.f)', siz3, nTime));
    
    % Propagate over D
    if siz3==1
        R = repmat(R, [1 1 nTime]);
    end
    
    % Check the covariance matrix in each time step
    for t = 1:nTime
        missing = isnan(D(:,t));
        Rt = R(~missing, ~missing, t);
        [row, col] = find(isnan(Rt), 1);
        assert(isempty(row), sprintf('You must specify an error-covariance between proxy sites %.f and %.f in time step %.f', row, col, t));
        assert(issymmetric(Rt), sprintf('Rcov is not a symmetric matrix for time step %.f.', t));
        assert( all(diag(Rt)>0), sprintf('The diagonal elements of the error-covariance for time step %.f must all be positive', t));
    end
end

% Set values
obj.D = D;
obj.R = R;
obj.Rcov = isCovariance;
obj.nSite = nSite;
obj.nTime = nTime;

end
