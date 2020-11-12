function[kf] = blend(kf, C, Ycov, weights, whichCov)
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

% Cannot blend if the covariance was already set
if ~isempty(kf.C) && kf.setC
    setCovarianceError;
end

% Only provide blending after the prior and observations are set
kf.assertEditableCovariance('covariance blending options');

% Error check the covariance options. Get sizes
if ~exist('whichCov', 'var') || isempty(whichCov)
    whichCov = [];
end
[whichCov, nCov] = kf.checkCovariance(C, Ycov, whichCov);

% Default and error check weights
if ~exist('weights','var') || isempty(weights)
    weights = ones(nCov, 1);
end
[nRows, nCols] = kf.checkInput(weights, 'weights', false, true);
assert( all(weights>0,'all'), 'blending weights must be positive');
assert( nCols<3, 'weights cannot have more than 2 columns');

% Propagate/default weights
if nCols == 1
    weights = cat(2, weights, ones(size(weights)));
end
if nRows==1
    weights = repmat(weights, [nCov, 1]);
elseif nRows~=nCov
    weightsRowsError(nCov, nRows);
end

% Save
kf.C = C;
kf.setC = false;
kf.Ycov = Ycov;
kf.whichCov = whichCov;
kf.weights = weights;

end

% Long error messages
function[] = setCovarianceError
error(['You cannot blend the covariance because you already set the ',...
    'covariance directly using the "setCovariance" command. See the ',...
    '"resetCovariance" command if you want to reset covariance options.']);
end
function[] = weightsRowsError(nCov, nRows)
error(['weights must either have 1 row, or %.f rows (one per covariance). ',...
    'Instead, weights has %.f rows.'], nCov, nRows);
end