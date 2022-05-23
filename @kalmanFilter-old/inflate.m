function[kf] = inflate(kf, factor, whichFactor)
%% Specify an inflation factor.
%
% kf = kf.inflate( factor )
% Specifies a multiplicative covariance inflation factor.
%
% kf = kf.inflate(factors, whichFactor)
% Specifies different inflation factors in different time steps.
%
% ----- Inputs -----
%
% factors: A numeric vector of values greater than 1.
%
% whichFactor: A vector with one element per time step. Each element is the
%    index of the inflation factor to use for that time step.
%
% ----- Outputs -----
%
% kf: The updated kalman filter object

% Only provide inflation after the prior and observations are set
kf.assertEditableCovariance('covariance inflation options');

% Error check the inflation factors
dash.assert.vectorTypeN(factor, 'numeric', [], 'factor');
dash.assert.realDefined(factor, 'factor');
assert(all(factor>=1), 'inflation factors cannot be smaller than 1.');

% Default and error check whichFactor
if ~exist('whichFactor','var') || isempty(whichFactor)
    whichFactor = [];
end
whichFactor = kf.parseWhich(whichFactor, 'whichFactor', numel(factor), 'inflation factor', false);

% Save
kf.inflateFactor = factor;
kf.inflateCov = true;
kf.whichFactor = whichFactor;

end