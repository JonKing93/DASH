function[kf] = blend(kf, C, Ycov, weights, whichCov)
%% Blends ensemble covariance with a climatological covariance.
%
% kf = kf.blend(C, Ycov)
% Blends a climatological covariance with the ensemble covariance using a
% weighting of 50% climatological covarinace and 50% ensemble covariance.
%
% kf = kf.blend(C, Ycov, coeffs)
% Specify weights for both covariances.
%
% kf = kf.blend(C, Ycov, coeffs, whichCov)
% Specify different blending options in different time steps.
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
% coeffs: Weights for both the climatological and ensemble covariances. A
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

% Cannot blend if the covariance was already set, or if the prior or
% observations are missing
if kf.setCov
    setCovarianceError;
end
kf.assertEditableCovariance('covariance blending options');

% Error check the covariance options. Get sizes
if ~exist('whichCov', 'var') || isempty(whichCov)
    whichCov = [];
end
[whichCov, nCov] = kf.checkCovariance(C, Ycov, whichCov);

% Default and error check weights
if ~exist('weights','var') || isempty(weights)
    weights = 0.5 * ones(nCov, 2);
end
[nRows, nCols] = kf.checkInput(weights, 'weights', false, true);
assert( all(weights>0,'all'), 'blending weights must be positive');
assert( nCols==2, 'blending coefficients must have 2 columns');

% Propagate weights
if nRows==1
    weights = repmat(weights, [nCov, 1]);
elseif nRows~=nCov
    weightsRowsError(nCov, nRows);
end

% Save
kf.C = C;
kf.blendCov = true;
kf.Ycov = Ycov;
kf.whichCov = whichCov;
kf.blendWeights = weights;

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