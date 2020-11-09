function[kf] = blend(C, Ycov, weights, whichCov)
%% Blends ensemble covariance with a climatological covariance.
%
% kf = kf.blend(C, Ycov)
% Blends a climatological covariance with the ensemble covariance. Gives
% equal weight to the two covariances.
%
% kf = kf.blend(C, Ycov, b)
% Specify the weight for the climatological covariance. Weights the
% ensemble covariance by 1 and the climatological covariance by b.
%
% kf = kf.blend(C, Ycov, weights)
% Specify weights for both covariances.
%
% kf = kf.blend(C, Ycov, weights, whichCov)
% Specify different climatological covariances to blend in different time
% steps.
%
% ----- Inputs -----
%
% C: The climatological covariance of each observation/proxy site with the
%    state vector. A numeric matrix (nState x nSite)
%
%    If blending different covariances in different time steps, then an
%    array (nState x nSite x nCov)
%
% Ycov: The climatological covariance of each observation/proxy site with
%    the other observation/proxy sites. (nSite x nSite)
%
%    If blending different covariances in different time steps, then an
%    array (nSite x nSite x nCov)
%
% b: A weight for the climatological covariance. The weight for the
%    ensemble covariance is set to 1. Use a scalar to use the same weight
%    for all specified climatological covariances. Use a column vector with
%    one element per climatological covariance (nCov) to specify different
%    weights for different covariances. All weights must be positive.
%
% weights: Weights for both the climatological and ensemble covariances. A
%    numeric matrix with two columns. The first column is the weight of the
%    climatological covariance. The second column is the weight of the
%    ensemble covariance. Use one row to apply the same weights to all
%    specified climatological covariance. Use one row per covariance (nCov) 
%    to apply different weights to each covariance. All weights must be
%    positive.
%
% whichCov: A vector with one element per time step. Each element is the
%    index of the covariance to blend for that time step. The indices refer
%    to the elements along the third dimension of C.
%     
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Only allow blending after the prior and observations are set
if isempty(kf.M)
    error(['You must specify a prior (using the "prior" command) before setting ',...
        'covariance blending options. If you would instead like to directly set the covariance, ',...
        'directly, see the "setCovariance" command.']);
elseif isempty(kf.D)
    error(['You must specify the observations/proxies (using the "observations" ',...
        'command before setting covariance blending options. ']);
end

% Error check the covariance
[nState, nSite, nCov] = kf.checkInput(C, 'C');
if nSite ~= kf.nSite
    error('C must have one column per observation/proxy site (%.f), but instead has %.f columns', kf.nSite, nSite);
elseif nState ~= kf.nState
    error('C must have one row per state vector element (%.f), but instead has %.f rows', kf.nState, nState);
end

% Error check the Y covariance
[nSite, nSite2, nCov2] = kf.checkInput(Ycov, 'Ycov');
if nSite ~= kf.nSite
    error('Ycov must have one row per observation/proxy site (%.f), but instead has %.f rows', kf.nSite, nSite);
elseif nSite~=nSite2
    error('Ycov must have the same number of rows as columns. Instead, it has %.f rows and %.f columns.' nSite, nSite2);
elseif nCov ~= nCov2
    error(['Ycov must specify the same number of climatological covariance as ',...
        'C (%.f). Instead, Ycov has %.f elements along the third dimension.'], nCov, nCov2);
end

% Default and error check weights
if ~exist('weights','var') || isempty(weight)
    weights = ones(nCov, 1);
end
[nRows, nCols] = kf.checkInput(weights, 'weights', false, true);
assert(~any(weights(:)<=0), 'All weights must be positive');
assert(nCols<3, 'weights cannot have more than 2 columns');

% Input name (from column size) and default ensemble weights
weightName = 'weights';
if nCols==1
    weightName = 'b';
    weights = cat(2, weights, ones(size(weights)));
end

% Propagate weights over all covariances.
if nRows==1
    weights = repmat(weights, [nCov, 1]);
elseif nRows~=nCov
    error(['%s must have either 1 row, or 1 row per covariance (%.f). ',...
        'Instead, %s has %.f rows.'], weightName, nCov, weightName, nRows);
end

% Note if this is an evolving blend
isevolving = false;
if nCov > 1
    isevolving = true;
end

% If evolving, get the covariance to blend in each time step
isvar = exist('whichCov','var') && ~isempty(whichCov);
if isevolving
    if ~isvar && nCov==kf.nTime
        whichCov = 1:kf.nTime;
    elseif ~isvar
        error(['The number of climatological covariances (%.f) does not match ',...
            'the number of time steps (%.f), so you must use the fourth input (whichCov)', ...
            'to specify which climatological covariance to blend in each ',...
            'time step.'], nCov, kf.nTime);
    end
    
    % Error check whichCov
    dash.assertVectorTypeN(whichCov, 'numeric', kf.nTime, 'whichCov');
    dash.checkIndices(whichCov, 'whichCov', nCov, 'the number of climatological covariances');
    
% If not evolving, cannot select time steps
else
    if isvar
        error(['You only specified one climatological covariance, so you cannot ',...
            'use the fourth input (whichCov) to specify time steps.']);
    end
    whichCov = [];
end

% Save values
kf.C = C;
kf.Ycov = Ycov;
kf.weights = weights;
kf.whichCov = whichCov;

end